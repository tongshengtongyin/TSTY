import 'dart:async';

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
  RTCVideo? _rtcVideo;
  RTCRoom? _rtcRoom;

  final RTCVideoEventHandler _videoHandler = RTCVideoEventHandler();
  final RTCRoomEventHandler _roomHandler = RTCRoomEventHandler();

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
    if (_rtcVideo != null) return;

    _emitState(RtcAudioCallState.initializing);
    _initHandlers();

    try {
      _rtcVideo = await RTCVideo.createRTCVideo(
        RTCVideoContext(appId, eventHandler: _videoHandler),
      );
      if (_rtcVideo == null) {
        _emitState(RtcAudioCallState.error);
        _emitError('createRTCVideo_failed');
        return;
      }

      await _rtcVideo?.setDefaultAudioRoute(
        _speakerphone ? AudioRoute.speakerphone : AudioRoute.earpiece,
      );

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
    if (_rtcVideo == null) {
      throw StateError('RtcAudioCallService not initialized');
    }

    if (!await ensureMicrophonePermission()) {
      _emitState(RtcAudioCallState.error);
      _emitError('no_microphone_permission');
      return;
    }

    _emitState(RtcAudioCallState.joining);

    try {
      await _rtcRoom?.leaveRoom();
    } catch (_) {}

    try {
      await _rtcRoom?.destroy();
    } catch (_) {}

    _rtcRoom = null;
    _remoteUsers.clear();
    if (!_remoteUsersController.isClosed) {
      _remoteUsersController.add(remoteUsers);
    }

    try {
      _rtcRoom = await _rtcVideo?.createRTCRoom(roomId);
      _rtcRoom?.setRTCRoomEventHandler(_roomHandler);

      await _rtcVideo?.startAudioCapture();

      final userInfo = UserInfo(uid: userId);
      final roomConfig = RoomConfig(
        isPublishAudio: true,
        isPublishVideo: false,
        isAutoSubscribeAudio: true,
        isAutoSubscribeVideo: false,
      );

      await _rtcRoom?.joinRoom(
        token: token,
        userInfo: userInfo,
        roomConfig: roomConfig,
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
    if (_rtcVideo == null) return;

    try {
      await _rtcVideo?.setDefaultAudioRoute(
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
      await _rtcRoom?.publishStreamAudio(!muted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('setMuted failed: $e');
      }
    }
  }

  Future<void> leave() async {
    if (_rtcVideo == null) return;

    _emitState(RtcAudioCallState.leaving);
    try {
      await _rtcRoom?.leaveRoom();
    } catch (_) {}

    try {
      await _rtcVideo?.stopAudioCapture();
    } catch (_) {}

    _session = null;
    _emitState(RtcAudioCallState.ended);
  }

  Future<void> dispose() async {
    try {
      await leave();
    } catch (_) {}

    try {
      await _rtcRoom?.destroy();
    } catch (_) {}
    _rtcRoom = null;

    try {
      await _rtcVideo?.destroy();
    } catch (_) {}
    _rtcVideo = null;

    if (!_stateController.isClosed) await _stateController.close();
    if (!_errorController.isClosed) await _errorController.close();
    if (!_remoteUsersController.isClosed) await _remoteUsersController.close();
  }

  void _initHandlers() {
    _videoHandler.onWarning = (WarningCode code) {
      if (kDebugMode) debugPrint('RTC warning: $code');
    };

    _videoHandler.onError = (ErrorCode code) {
      if (kDebugMode) debugPrint('RTC error: $code');
      _emitState(RtcAudioCallState.error);
      _emitError('rtc_error_$code');
    };

    _roomHandler.onRoomStateChanged =
        (String roomId, String uid, int state, String extraInfo) {
      if (kDebugMode) {
        debugPrint('RTC roomState: roomId=$roomId uid=$uid state=$state extra=$extraInfo');
      }
      if (state == 0) {
        _emitState(RtcAudioCallState.joined);
      } else {
        _emitState(RtcAudioCallState.error);
        _emitError('join_room_failed_state_$state');
      }
    };

    _roomHandler.onUserJoined = (UserInfo userInfo, int elapsed) {
      if (kDebugMode) debugPrint('RTC userJoined: ${userInfo.uid}');
      final uid = userInfo.uid;
      if (uid.isEmpty) return;
      _remoteUsers.add(uid);
      if (!_remoteUsersController.isClosed) {
        _remoteUsersController.add(remoteUsers);
      }
    };

    _roomHandler.onUserLeave = (String uid, UserOfflineReason reason) {
      if (kDebugMode) debugPrint('RTC userLeave: $uid reason=$reason');
      if (uid.isEmpty) return;
      _remoteUsers.remove(uid);
      if (!_remoteUsersController.isClosed) {
        _remoteUsersController.add(remoteUsers);
      }
    };
  }
}
