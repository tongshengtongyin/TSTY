import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:volc_engine_rtc/volc_engine_rtc.dart';
import 'package:tsty_app/utils/yi_recorder.dart';

enum RtcAudioCallState {
  idle,
  initializing,
  joining,
  joined,
  leaving,
  ended,
  error,
}

class RtcAudioCallError {
  final String message;
  final Object? cause;

  const RtcAudioCallError(this.message, {this.cause});
}

class RtcAudioCallSession {
  final String roomId;
  final String userId;

  const RtcAudioCallSession({required this.roomId, required this.userId});
}

class RtcAudioCallService {
  RTCRoom? _rtcRoom;
  RTCEngine? _rtcEngine;

  final IRTCRoomEventHandler _roomHandler = IRTCRoomEventHandler();

  final StreamController<RtcAudioCallState> _stateController =
      StreamController<RtcAudioCallState>.broadcast();
  final StreamController<RtcAudioCallError?> _errorController =
      StreamController<RtcAudioCallError?>.broadcast();
  final StreamController<Set<String>> _remoteUsersController =
      StreamController<Set<String>>.broadcast();

  RtcAudioCallState _state = RtcAudioCallState.idle;
  RtcAudioCallSession? _session;

  final Set<String> _remoteUsers = <String>{};

  bool _speakerphone = true;
  bool _muted = false;

  Stream<RtcAudioCallState> get stateStream => _stateController.stream;
  Stream<RtcAudioCallError?> get errorStream => _errorController.stream;
  Stream<Set<String>> get remoteUsersStream => _remoteUsersController.stream;

  RtcAudioCallState get state => _state;
  RtcAudioCallSession? get session => _session;

  Set<String> get remoteUsers => Set<String>.unmodifiable(_remoteUsers);

  bool get speakerphone => _speakerphone;
  bool get muted => _muted;

  void _emitState(RtcAudioCallState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  void _emitError(String message, {Object? cause}) {
    if (!_errorController.isClosed) {
      _errorController.add(RtcAudioCallError(message, cause: cause));
    }
  }

  Future<bool> ensureMicrophonePermission() async {
    final tmp = YiRecorderController();
    try {
      return await tmp.hasPermission(request: true);
    } finally {
      tmp.dispose();
    }
  }

  Future<void> init({required String appId}) async {
    _emitState(RtcAudioCallState.initializing);

    try {
      // 使用正确的初始化方式：通过 createRTCEngine 静态方法创建引擎实例
      final context = RTCVideoContext(appId: appId);
      _rtcEngine = await RTCEngine.createRTCEngine(context);
      _emitState(RtcAudioCallState.idle);
    } catch (e) {
      _emitState(RtcAudioCallState.error);
      _emitError('init_failed', cause: e);
      rethrow;
    }
  }

  Future<void> join({
    required String roomId,
    required String userId,
    required String token,
  }) async {
    if (_rtcEngine == null) {
      throw StateError('RtcAudioCallService not initialized');
    }

    if (!await ensureMicrophonePermission()) {
      _emitState(RtcAudioCallState.error);
      _emitError('no_microphone_permission');
      return;
    }

    _emitState(RtcAudioCallState.joining);

    try {
      _rtcRoom = await _rtcEngine!.createRTCRoom(roomId);
      _rtcRoom!.setRTCRoomEventHandler(_roomHandler);

      // 修改：确保提供必需的extraInfo参数
      final userInfo = UserInfo(
        userId: userId,
        extraInfo: '',
      );

      final roomConfig = RoomConfig(
        profile: RoomProfile.communication,
      );

      _rtcRoom!.joinRoom(
        token: token,
        userInfo: userInfo,
        roomConfig: roomConfig,
        userVisibility: true,
      );

      _session = RtcAudioCallSession(roomId: roomId, userId: userId);
      _emitState(RtcAudioCallState.joined);

      if (_muted) {
        await setMuted(true);
      }
    } catch (e) {
      _emitState(RtcAudioCallState.error);
      _emitError('join_failed', cause: e);
      rethrow;
    }
  }

  Future<void> setSpeakerphone(bool enabled) async {
    _speakerphone = enabled;
    if (_rtcEngine == null) return;

    try {
      _rtcEngine!.setDefaultAudioRoute(
        enabled ? AudioRoute.speakerphone : AudioRoute.earpiece,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('setSpeakerphone failed: $e');
      }
    }
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    if (_rtcRoom == null) return;

    try {
      _rtcRoom!.publishStreamAudio(!muted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('setMuted failed: $e');
      }
    }
  }

  /// 发送触发新一轮对话指令(手动模式)
  /// 通过 RTC 发送二进制消息给 AI Bot,通知其用户发言结束
  Future<bool> sendFinishRecognitionMessage({required String botUserId}) async {
    if (_rtcRoom == null) {
      if (kDebugMode) {
        debugPrint('sendFinishRecognitionMessage failed: rtcRoom is null');
      }
      return false;
    }

    try {
      // 构建 JSON 消息内容
      final jsonContent = jsonEncode({'Command': 'FinishSpeechRecognition'});
      final jsonBytes = utf8.encode(jsonContent);

      // 构建 TLV 格式的二进制消息
      // magic_number (4 bytes: "ctrl") + length (4 bytes, big-endian) + value (json bytes)
      final magicNumber = utf8.encode('ctrl');
      final length = jsonBytes.length;

      final buffer = BytesBuilder();
      buffer.add(magicNumber);
      // 大端序写入 4 字节长度
      buffer.add([
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ]);
      buffer.add(jsonBytes);

      final binaryMessage = buffer.toBytes();

      if (kDebugMode) {
        debugPrint('sendFinishRecognitionMessage to $botUserId: $jsonContent');
      }

      // 修改：提供正确的config参数
      _rtcRoom!.sendUserBinaryMessage(
        userId: botUserId,
        buffer: binaryMessage,
        config: MessageConfig.reliable_ordered,
      );

      if (kDebugMode) {
        debugPrint('sendFinishRecognitionMessage success');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('sendFinishRecognitionMessage failed: $e');
      }
      return false;
    }
  }

  Future<void> leave() async {
    if (_rtcEngine == null) return;

    _emitState(RtcAudioCallState.leaving);
    try {
      _rtcRoom?.leaveRoom();
    } catch (_) {}

    _session = null;
    _emitState(RtcAudioCallState.ended);
  }

  Future<void> dispose() async {
    try {
      await leave();
    } catch (_) {}

    try {
      _rtcRoom?.destroy();
    } catch (_) {}
    _rtcRoom = null;

    try {
      _rtcEngine?.destroy();
    } catch (_) {}
    _rtcEngine = null;

    if (!_stateController.isClosed) await _stateController.close();
    if (!_errorController.isClosed) await _errorController.close();
    if (!_remoteUsersController.isClosed) await _remoteUsersController.close();
  }
}
