import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tsty_app/api/ai_voice_chat.dart';
import 'package:tsty_app/services/rtc_audio_call_service.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class RealtimeAiVoiceChatSessionInfo {
  final String appId;
  final String roomId;
  final String userId;
  final String taskId;
  final String? botUserId;
  final String? welcomeMessage;

  const RealtimeAiVoiceChatSessionInfo({
    required this.appId,
    required this.roomId,
    required this.userId,
    required this.taskId,
    this.botUserId,
    this.welcomeMessage,
  });
}

class RealtimeAiVoiceChatSession {
  final RtcAudioCallService _rtc;

  RealtimeAiVoiceChatSessionInfo? _info;
  bool _started = false;

  RealtimeAiVoiceChatSession(this._rtc);

  RealtimeAiVoiceChatSessionInfo? get info => _info;

  bool get started => _started;

  static String _safeId(String s, {int maxLen = 64}) {
    final cleaned = s.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    if (cleaned.length <= maxLen) return cleaned;
    return cleaned.substring(0, maxLen);
  }

  static String _randomSuffix() {
    final r = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List<String>.generate(
      6,
      (_) => chars[r.nextInt(chars.length)],
    ).join();
  }

  Future<RealtimeAiVoiceChatSessionInfo> start({
    required String sceneId,
  }) async {
    if (_started) {
      final existing = _info;
      if (existing != null) return existing;
      throw StateError('session state invalid');
    }
    var stage = 'init';
    try {
      final deviceId = await UserPrefs.getOrCreateDeviceId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final roomId = _safeId('room_${deviceId}_$now', maxLen: 64);
      final taskId = _safeId('task_${now}_${_randomSuffix()}', maxLen: 64);

      if (kDebugMode) {
        debugPrint(
          'AI session start: sceneId=$sceneId deviceId=$deviceId roomId=$roomId taskId=$taskId',
        );
      }

      stage = 'rtc_token';
      final tokenResp = await getAiRtcTokenAPI(roomId: roomId);
      final appId = tokenResp['appId']?.toString() ?? '';
      final effectiveRoomId = tokenResp['roomId']?.toString() ?? roomId;
      final userId = tokenResp['userId']?.toString() ?? '';
      final rtcToken = tokenResp['token']?.toString() ?? '';

      if (kDebugMode) {
        debugPrint(
          'AI rtc-token parsed: appId=$appId roomId=$effectiveRoomId userId=$userId tokenLen=${rtcToken.length}',
        );
      }

      if (appId.isEmpty || rtcToken.isEmpty || userId.isEmpty) {
        throw Exception('RTC Token 响应缺少 appId/userId/token');
      }

      stage = 'rtc_init';
      await _rtc.init(appId: appId);

      stage = 'rtc_join';
      await _rtc.join(roomId: effectiveRoomId, userId: userId, token: rtcToken);

      stage = 'character';
      final selected = await UserPrefs.getSelectedCharacter();
      final characterId = selected == 0 ? 'ayimo' : 'aniure';

      if (kDebugMode) {
        debugPrint(
          'AI voicechat characterId=$characterId (selected=$selected)',
        );
      }

      stage = 'voicechat_start';
      final startResp = await startAiVoiceChatAPI(
        roomId: effectiveRoomId,
        taskId: taskId,
        characterId: characterId,
        sceneId: sceneId,
      );

      if (kDebugMode) {
        debugPrint('AI voicechat start parsed: $startResp');
      }

      final success = startResp['success'] == true;
      if (!success) {
        final msg =
            startResp['errorMessage']?.toString() ??
            startResp['message']?.toString() ??
            'StartVoiceChat failed';
        throw Exception(msg);
      }

      final botUserId = startResp['botUserId']?.toString();
      final welcomeMessage = startResp['welcomeMessage']?.toString();

      final info = RealtimeAiVoiceChatSessionInfo(
        appId: appId,
        roomId: effectiveRoomId,
        userId: userId,
        taskId: taskId,
        botUserId: botUserId,
        welcomeMessage: welcomeMessage,
      );

      _info = info;
      _started = true;

      if (kDebugMode) {
        debugPrint(
          'Realtime AI voice chat started: appId=${info.appId} roomId=${info.roomId} userId=${info.userId} taskId=${info.taskId}',
        );
      }

      return info;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AI session start failed at stage=$stage: $e');
      }

      // If we already initialized/joined RTC but failed later (e.g. start voicechat),
      // clean up room/capture so the next retry starts from a clean state.
      try {
        await _rtc.leave();
      } catch (_) {}

      throw Exception('AI session start failed at $stage: $e');
    }
  }

  Future<void> stop() async {
    if (!_started) return;
    final info = _info;
    if (info != null) {
      try {
        if (kDebugMode) {
          debugPrint(
            'AI session stop: roomId=${info.roomId} taskId=${info.taskId}',
          );
        }
        await stopAiVoiceChatAPI(roomId: info.roomId, taskId: info.taskId);
      } catch (_) {}
    }

    try {
      await _rtc.dispose();
    } catch (_) {}

    _started = false;
    _info = null;
  }
}
