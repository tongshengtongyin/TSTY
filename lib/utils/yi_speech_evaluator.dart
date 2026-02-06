import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'yi_file_bytes.dart' show yiReadFileBytes;

class YiIseAuthQuery {
  final String authorization;
  final String host;
  final String date;

  const YiIseAuthQuery({
    required this.authorization,
    required this.host,
    required this.date,
  });

  Uri applyTo(Uri base) {
    return base.replace(
      queryParameters: <String, String>{
        ...base.queryParameters,
        'authorization': authorization,
        'host': host,
        'date': date,
      },
    );
  }
}

class YiIseConfig {
  final Uri endpoint;
  final String appId;

  final String category;
  final String ent;
  final String sub;

  final String tte;
  final bool ttpSkip;

  final String aue;
  final String auf;

  final int bytesPerFrame;
  final Duration frameInterval;

  final bool stripWavHeader;

  const YiIseConfig({
    required this.endpoint,
    required this.appId,
    required this.category,
    required this.ent,
    this.sub = 'ise',
    this.tte = 'utf-8',
    this.ttpSkip = true,
    this.aue = 'raw',
    this.auf = 'audio/L16;rate=16000',
    this.bytesPerFrame = 1280,
    this.frameInterval = const Duration(milliseconds: 40),
    this.stripWavHeader = true,
  });

  YiIseConfig copyWith({
    Uri? endpoint,
    String? appId,
    String? category,
    String? ent,
    String? sub,
    String? tte,
    bool? ttpSkip,
    String? aue,
    String? auf,
    int? bytesPerFrame,
    Duration? frameInterval,
    bool? stripWavHeader,
  }) {
    return YiIseConfig(
      endpoint: endpoint ?? this.endpoint,
      appId: appId ?? this.appId,
      category: category ?? this.category,
      ent: ent ?? this.ent,
      sub: sub ?? this.sub,
      tte: tte ?? this.tte,
      ttpSkip: ttpSkip ?? this.ttpSkip,
      aue: aue ?? this.aue,
      auf: auf ?? this.auf,
      bytesPerFrame: bytesPerFrame ?? this.bytesPerFrame,
      frameInterval: frameInterval ?? this.frameInterval,
      stripWavHeader: stripWavHeader ?? this.stripWavHeader,
    );
  }
}

class YiIseProgress {
  final String? sid;
  final int code;
  final String message;
  final int status;
  final String? xmlChunk;

  const YiIseProgress({
    required this.sid,
    required this.code,
    required this.message,
    required this.status,
    required this.xmlChunk,
  });

  bool get isFinal => status == 2;
}

class YiIseResult {
  final String sid;
  final String xml;

  const YiIseResult({
    required this.sid,
    required this.xml,
  });

  double? get totalScore => YiIseXml.extractTotalScore(xml);
}

class YiIseXml {
  static double? _extractAttrDouble(String xml, String attr) {
    final m = RegExp('$attr\\s*=\\s*"([0-9]+(?:\\.[0-9]+)?)"')
        .firstMatch(xml);
    if (m == null) return null;
    return double.tryParse(m.group(1) ?? '');
  }

  static int? _extractAttrInt(String xml, String attr) {
    final m = RegExp('$attr\\s*=\\s*"(-?[0-9]+)"').firstMatch(xml);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }

  static double? extractTotalScore(String xml) {
    return _extractAttrDouble(xml, 'total_score');
  }

  static double? extractFluencyScore(String xml) {
    return _extractAttrDouble(xml, 'fluency_score');
  }

  static double? extractIntegrityScore(String xml) {
    return _extractAttrDouble(xml, 'integrity_score');
  }

  static double? extractToneScore(String xml) {
    return _extractAttrDouble(xml, 'tone_score');
  }

  static double? extractPhoneScore(String xml) {
    return _extractAttrDouble(xml, 'phone_score');
  }

  static int? extractExceptInfo(String xml) {
    return _extractAttrInt(xml, 'except_info');
  }
}

class YiIseException implements Exception {
  final int code;
  final String message;

  const YiIseException(this.code, this.message);

  @override
  String toString() => 'YiIseException(code: $code, message: $message)';
}

class YiIseEvaluator {
  final YiIseConfig config;

  YiIseEvaluator(this.config);

  bool _trySinkAdd(WebSocketChannel channel, Object data) {
    try {
      channel.sink.add(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<YiIseProgress> evaluateBytes({
    required Uint8List audioBytes,
    required String text,
    YiIseAuthQuery? authQuery,
    void Function(YiIseProgress p)? onProgress,
    Duration? timeout,
  }) {
    final controller = StreamController<YiIseProgress>.broadcast();
    unawaited(_evaluateInternal(
      audioBytes: audioBytes,
      text: text,
      authQuery: authQuery,
      controller: controller,
      onProgress: onProgress,
      timeout: timeout,
    ));
    return controller.stream;
  }

  Future<YiIseResult> evaluateBytesToResult({
    required Uint8List audioBytes,
    required String text,
    YiIseAuthQuery? authQuery,
    void Function(YiIseProgress p)? onProgress,
    Duration? timeout,
  }) async {
    final xmlBuffer = StringBuffer();
    String? sid;

    await for (final p in evaluateBytes(
      audioBytes: audioBytes,
      text: text,
      authQuery: authQuery,
      onProgress: (e) {
        onProgress?.call(e);
        if (e.xmlChunk != null) {
          xmlBuffer.write(e.xmlChunk);
        }
        sid ??= e.sid;
      },
      timeout: timeout,
    )) {
      if (p.code != 0) {
        throw YiIseException(p.code, p.message);
      }
      if (p.isFinal) {
        final resultSid = (p.sid ?? sid ?? '').trim();
        if (resultSid.isEmpty) {
          throw const YiIseException(-1, 'missing_sid');
        }
        return YiIseResult(sid: resultSid, xml: xmlBuffer.toString());
      }
    }

    throw const YiIseException(-1, 'no_final_result');
  }

  Future<YiIseResult> evaluateFileToResult({
    required String filePath,
    required String text,
    YiIseAuthQuery? authQuery,
    void Function(YiIseProgress p)? onProgress,
    Duration? timeout,
  }) async {
    final bytes = await yiReadFileBytes(filePath);
    return evaluateBytesToResult(
      audioBytes: bytes,
      text: text,
      authQuery: authQuery,
      onProgress: onProgress,
      timeout: timeout,
    );
  }

  Future<void> _evaluateInternal({
    required Uint8List audioBytes,
    required String text,
    required YiIseAuthQuery? authQuery,
    required StreamController<YiIseProgress> controller,
    void Function(YiIseProgress p)? onProgress,
    Duration? timeout,
  }) async {
    WebSocketChannel? channel;
    StreamSubscription? sub;
    Timer? timeoutTimer;

    void emit(YiIseProgress p) {
      if (controller.isClosed) return;
      controller.add(p);
      onProgress?.call(p);
    }

    try {
      final endpoint = authQuery?.applyTo(config.endpoint) ?? config.endpoint;
      if (kDebugMode) {
        debugPrint('ISE WS connect: $endpoint');
      }
      channel = WebSocketChannel.connect(endpoint);

      if (timeout != null) {
        timeoutTimer = Timer(timeout, () {
          try {
            channel?.sink.close(ws_status.goingAway);
          } catch (_) {}
        });
      }

      sub = channel.stream.listen((event) {
        try {
          final msg = event is String ? event : utf8.decode(event as List<int>);
          final obj = jsonDecode(msg);
          if (obj is! Map) return;

          final code = (obj['code'] is int)
              ? obj['code'] as int
              : int.tryParse('${obj['code']}') ?? -1;
          final message = (obj['message'] ?? '').toString();
          final sid = obj['sid']?.toString();

          int status = -1;
          String? xmlChunk;
          final data = obj['data'];
          if (data is Map) {
            status = (data['status'] is int)
                ? data['status'] as int
                : int.tryParse('${data['status']}') ?? -1;
            final payload = data['data'];
            if (payload is String && payload.isNotEmpty) {
              try {
                final decoded = base64Decode(payload);
                xmlChunk = utf8.decode(decoded, allowMalformed: true);
              } catch (_) {
                xmlChunk = null;
              }
            }
          }

          if (kDebugMode) {
            debugPrint(
              'ISE WS recv: code=$code status=$status sid=${sid ?? ''} message=$message',
            );
          }

          emit(YiIseProgress(
            sid: sid,
            code: code,
            message: message,
            status: status,
            xmlChunk: xmlChunk,
          ));

          if (code != 0 || status == 2) {
            try {
              channel?.sink.close(ws_status.normalClosure);
            } catch (_) {}
          }
        } catch (_) {}
      }, onError: (_) {
        emit(const YiIseProgress(
          sid: null,
          code: -1,
          message: 'ws_error',
          status: -1,
          xmlChunk: null,
        ));
      }, onDone: () {
        if (!controller.isClosed) {
          unawaited(controller.close());
        }
      });

      final bomText = text.startsWith('\uFEFF') ? text : '\uFEFF$text';

      final ssb = {
        'common': {
          'app_id': config.appId,
        },
        'business': {
          'aue': config.aue,
          'auf': config.auf,
          'category': config.category,
          'cmd': 'ssb',
          'ent': config.ent,
          'sub': config.sub,
          'text': bomText,
          'tte': config.tte,
          'ttp_skip': config.ttpSkip,
        },
        'data': {
          'status': 0,
        },
      };

      if (!_trySinkAdd(channel, jsonEncode(ssb))) {
        emit(const YiIseProgress(
          sid: null,
          code: -1,
          message: 'ws_closed',
          status: -1,
          xmlChunk: null,
        ));
        return;
      }

      final bytes = _maybeStripWavHeader(audioBytes);
      final ok = await _sendAudioFrames(channel, bytes);
      if (!ok) {
        emit(const YiIseProgress(
          sid: null,
          code: -1,
          message: 'ws_closed',
          status: -1,
          xmlChunk: null,
        ));
        return;
      }

      await sub.asFuture<void>();
    } catch (_) {
      emit(const YiIseProgress(
        sid: null,
        code: -1,
        message: 'send_error',
        status: -1,
        xmlChunk: null,
      ));
    } finally {
      timeoutTimer?.cancel();
      await sub?.cancel();
      try {
        channel?.sink.close(ws_status.normalClosure);
      } catch (_) {}
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  Uint8List _maybeStripWavHeader(Uint8List bytes) {
    if (!config.stripWavHeader) return bytes;
    if (bytes.length < 44) return bytes;

    final isRiff = bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46;
    final isWave = bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;
    if (!isRiff || !isWave) return bytes;

    final dataStart = _findWavDataStart(bytes);
    if (dataStart == null) return bytes;
    if (dataStart >= bytes.length) return bytes;

    return Uint8List.sublistView(bytes, dataStart);
  }

  int? _findWavDataStart(Uint8List bytes) {
    int i = 12;
    while (i + 8 <= bytes.length) {
      final id0 = bytes[i];
      final id1 = bytes[i + 1];
      final id2 = bytes[i + 2];
      final id3 = bytes[i + 3];
      final size = bytes[i + 4] |
          (bytes[i + 5] << 8) |
          (bytes[i + 6] << 16) |
          (bytes[i + 7] << 24);

      final isData = id0 == 0x64 && id1 == 0x61 && id2 == 0x74 && id3 == 0x61;
      final next = i + 8 + size;
      if (isData) {
        return i + 8;
      }
      if (size < 0 || next <= i) break;
      i = next;
    }
    return null;
  }

  Future<bool> _sendAudioFrames(WebSocketChannel channel, Uint8List bytes) async {
    if (bytes.isEmpty) {
      final last = {
        'business': {
          'cmd': 'auw',
          'aus': 4,
        },
        'data': {
          'status': 2,
          'data': '',
        },
      };
      return _trySinkAdd(channel, jsonEncode(last));
    }

    final frameSize = config.bytesPerFrame;
    if (bytes.length <= frameSize) {
      final first = {
        'business': {
          'cmd': 'auw',
          'aus': 1,
        },
        'data': {
          'status': 1,
          'data': base64Encode(bytes),
        },
      };
      if (!_trySinkAdd(channel, jsonEncode(first))) return false;
      await Future<void>.delayed(config.frameInterval);

      final last = {
        'business': {
          'cmd': 'auw',
          'aus': 4,
        },
        'data': {
          'status': 2,
          'data': '',
        },
      };
      return _trySinkAdd(channel, jsonEncode(last));
    }

    int offset = 0;
    int index = 0;

    while (offset < bytes.length) {
      final end = (offset + frameSize <= bytes.length)
          ? offset + frameSize
          : bytes.length;
      final chunk = Uint8List.sublistView(bytes, offset, end);
      final isFirst = index == 0;
      final isLast = end >= bytes.length;

      final aus = isLast
          ? 4
          : isFirst
              ? 1
              : 2;

      final status = isLast ? 2 : 1;

      final frame = {
        'business': {
          'cmd': 'auw',
          'aus': aus,
        },
        'data': {
          'status': status,
          'data': base64Encode(chunk),
        },
      };

      if (!_trySinkAdd(channel, jsonEncode(frame))) return false;

      if (!isLast) {
        await Future<void>.delayed(config.frameInterval);
      }

      offset = end;
      index += 1;
    }

    return true;
  }
}
