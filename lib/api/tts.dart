import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

Future<TtsAuthCache> getTtsAuthAPI({String? accessToken}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? null
      : <String, dynamic>{'Authorization': 'Bearer $token'};

  if (kDebugMode) {
    debugPrint(
      'TTS auth request: ${GlobalConstants.apiBaseUrl}${HttpConstants.ttsAuth} '
      'authHeader=${headers == null ? 'none' : 'bearer'}',
    );
  }

  final result = await dioUtils.get(HttpConstants.ttsAuth, headers: headers);

  if (result is! Map) {
    throw Exception('鉴权数据格式错误');
  }

  if (kDebugMode) {
    debugPrint('TTS auth response raw: ${jsonEncode(result)}');
  }

  final authorization = result['authorization']?.toString() ?? '';
  final date = result['date']?.toString() ?? '';
  final host = result['host']?.toString() ?? '';
  final appId =
      (result['appId'] ?? result['app_id'] ?? result['appid'])?.toString() ??
      '';
  final serviceType =
      result['serviceType']?.toString() ??
      result['service_type']?.toString() ??
      '';

  if (authorization.isEmpty || date.isEmpty || host.isEmpty || appId.isEmpty) {
    throw Exception('鉴权数据缺失');
  }

  if (kDebugMode) {
    debugPrint(
      'TTS auth response parsed: appId=$appId host=$host date=$date '
      'authorizationLen=${authorization.length} serviceType=$serviceType',
    );
  }

  return TtsAuthCache(
    authorization: authorization,
    date: date,
    host: host,
    appId: appId,
    serviceType: serviceType,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );
}

class TtsAuthCache {
  final String authorization;
  final String date;
  final String host;
  final String appId;
  final String serviceType;
  final int timestamp;

  const TtsAuthCache({
    required this.authorization,
    required this.date,
    required this.host,
    required this.appId,
    required this.serviceType,
    required this.timestamp,
  });
}
