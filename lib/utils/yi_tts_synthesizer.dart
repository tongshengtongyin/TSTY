import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'package:tsty_app/utils/yi_speech_evaluator.dart';

class YiTtsConfig {
  final Uri endpoint;
  final String appId;
  final String vcn;
  final String serviceType;
  final int speed;
  final int volume;
  final int pitch;

  const YiTtsConfig({
    required this.endpoint,
    required this.appId,
    required this.vcn,
    this.serviceType = 'tts',
    this.speed = 50,
    this.volume = 50,
    this.pitch = 50,
  });
}

class YiTtsException implements Exception {
  final int code;
  final String message;

  const YiTtsException(this.code, this.message);

  @override
  String toString() => 'YiTtsException(code: $code, message: $message)';
}

class YiTtsSynthesizer {
  final YiTtsConfig config;

  YiTtsSynthesizer(this.config);

  Future<Uint8List> synthesizeToBytes({
    required String text,
    required YiIseAuthQuery authQuery,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final endpoint = authQuery.applyTo(config.endpoint);
    if (kDebugMode) {
      debugPrint('TTS WS connect: $endpoint');
    }

    final buffer = BytesBuilder(copy: false);
    WebSocketChannel? channel;
    StreamSubscription? sub;

    final completer = Completer<void>();
    Timer? timeoutTimer;

    void completeOnce([Object? error, StackTrace? st]) {
      if (completer.isCompleted) return;
      if (error != null) {
        completer.completeError(error, st);
      } else {
        completer.complete();
      }
    }

    try {
      channel = WebSocketChannel.connect(endpoint);

      timeoutTimer = Timer(timeout, () {
        try {
          channel?.sink.close(ws_status.goingAway);
        } catch (_) {}
        completeOnce(const YiTtsException(-1, 'tts_timeout'));
      });

      sub = channel.stream.listen(
        (event) {
          try {
            final msg = event is String ? event : utf8.decode(event as List<int>);
            final obj = jsonDecode(msg);
            if (obj is! Map) return;

            final header = obj['header'];
            final headerMap = header is Map ? header : const <String, dynamic>{};
            final code = (headerMap['code'] is int)
                ? headerMap['code'] as int
                : int.tryParse('${headerMap['code']}') ?? 0;
            final message = (headerMap['message'] ?? '').toString();

            if (kDebugMode) {
              debugPrint('TTS WS recv: code=$code message=$message');
            }

            if (code != 0) {
              completeOnce(YiTtsException(code, message.isEmpty ? 'tts_error' : message));
              try {
                channel?.sink.close(ws_status.normalClosure);
              } catch (_) {}
              return;
            }

            final payload = obj['payload'];
            if (payload is! Map) return;

            final audioObj = payload['audio'];
            if (audioObj is! Map) return;

            final audioBase64 = (audioObj['audio'] ?? '').toString();
            if (audioBase64.isNotEmpty) {
              try {
                buffer.add(base64Decode(audioBase64));
              } catch (_) {}
            }

            final status = (audioObj['status'] is int)
                ? audioObj['status'] as int
                : int.tryParse('${audioObj['status']}') ?? -1;

            if (status == 2) {
              try {
                channel?.sink.close(ws_status.normalClosure);
              } catch (_) {}
              completeOnce();
            }
          } catch (_) {
            // ignore decode errors
          }
        },
        onError: (e, st) {
          completeOnce(const YiTtsException(-1, 'tts_ws_error'), st);
        },
        onDone: () {
          completeOnce();
        },
      );

      final request = _buildRequest(text);
      channel.sink.add(jsonEncode(request));

      await completer.future;

      final bytes = buffer.toBytes();
      if (bytes.isEmpty) {
        throw const YiTtsException(-1, 'tts_empty_audio');
      }
      return bytes;
    } finally {
      timeoutTimer?.cancel();
      await sub?.cancel();
      try {
        channel?.sink.close(ws_status.normalClosure);
      } catch (_) {}
    }
  }

  Map<String, dynamic> _buildRequest(String text) {
    final textBytes = utf8.encode(text);
    final textBase64 = base64Encode(textBytes);

    return <String, dynamic>{
      'header': {
        'app_id': config.appId,
        'status': 2,
        'service_type': config.serviceType,
      },
      'parameter': {
        'tts': {
          'vcn': config.vcn,
          'speed': config.speed,
          'volume': config.volume,
          'pitch': config.pitch,
          'bgs': 0,
          'reg': 0,
          'rdn': 0,
          'rhy': 0,
          'audio': {
            'encoding': 'lame',
            'sample_rate': 24000,
            'channels': 1,
            'bit_depth': 16,
            'frame_size': 0,
          },
        },
      },
      'payload': {
        'text': {
          'encoding': 'utf8',
          'compress': 'raw',
          'format': 'plain',
          'status': 2,
          'seq': 0,
          'text': textBase64,
        },
      },
    };
  }
}
