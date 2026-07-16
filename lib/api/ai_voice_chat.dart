import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

Future<Map<String, dynamic>> getAiRtcTokenAPI({
  required String roomId,
  String? accessToken,
}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? <String, dynamic>{'Content-Type': 'application/json'}
      : <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  final body = <String, dynamic>{'roomId': roomId};

  if (kDebugMode) {
    debugPrint('AI rtc-token request: roomId=$roomId');
  }

  final result = await dioUtils.post(
    HttpConstants.aiRtcToken,
    data: body,
    headers: headers,
  );

  if (kDebugMode) {
    debugPrint('AI rtc-token response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  throw Exception('RTC Token 数据格式错误');
}

Future<Map<String, dynamic>> startAiVoiceChatAPI({
  required String roomId,
  required String taskId,
  required String characterId,
  String? sceneId,
  String? accessToken,
}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? <String, dynamic>{'Content-Type': 'application/json'}
      : <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  final body = <String, dynamic>{
    'roomId': roomId,
    'taskId': taskId,
    'characterId': characterId,
    if (sceneId != null && sceneId.trim().isNotEmpty) 'sceneId': sceneId.trim(),
    'ASRConfig': {
      'TurnDetectionMode': 1, // 手动触发模式
      'VADConfig': {
        'SilenceTime': 2000, // 较长的静音时间，避免自动触发
      },
    },
  };

  if (kDebugMode) {
    debugPrint(
      'AI voicechat start request: roomId=$roomId taskId=$taskId characterId=$characterId sceneId=${sceneId ?? ''} body=$body',
    );
  }

  final result = await dioUtils.post(
    HttpConstants.aiVoiceChatStart,
    data: body,
    headers: headers,
  );

  if (kDebugMode) {
    debugPrint('AI voicechat start response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  throw Exception('StartVoiceChat 数据格式错误');
}

Future<void> stopAiVoiceChatAPI({
  required String roomId,
  required String taskId,
  String? accessToken,
}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? <String, dynamic>{'Content-Type': 'application/json'}
      : <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  final body = <String, dynamic>{'roomId': roomId, 'taskId': taskId};

  if (kDebugMode) {
    debugPrint('AI voicechat stop request: roomId=$roomId taskId=$taskId');
  }

  await dioUtils.post(
    HttpConstants.aiVoiceChatStop,
    data: body,
    headers: headers,
  );
}
