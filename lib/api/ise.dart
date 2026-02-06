import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

Future<IseAuthCache> getIseAuthAPI({String? accessToken}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? null
      : <String, dynamic>{
          'Authorization': 'Bearer $token',
        };

  if (kDebugMode) {
    debugPrint('ISE auth request: ${GlobalConstants.apiBaseUrl}${HttpConstants.iseAuth} '
        'authHeader=${headers == null ? 'none' : 'bearer'}');
  }

  final result = await dioUtils.get(
    HttpConstants.iseAuth,
    headers: headers,
  );

  if (result is! Map) {
    throw Exception('鉴权数据格式错误');
  }

  if (kDebugMode) {
    debugPrint('ISE auth response raw: ${jsonEncode(result)}');
  }

  final authorization = result['authorization']?.toString() ?? '';
  final date = result['date']?.toString() ?? '';
  final host = result['host']?.toString() ?? '';
  final appId = (result['appId'] ?? result['app_id'] ?? result['appid'])
          ?.toString() ??
      '';

  if (authorization.isEmpty || date.isEmpty || host.isEmpty || appId.isEmpty) {
    throw Exception('鉴权数据缺失');
  }

  if (kDebugMode) {
    debugPrint('ISE auth response parsed: appId=$appId host=$host date=$date '
        'authorizationLen=${authorization.length}');
  }

  return IseAuthCache(
    authorization: authorization,
    date: date,
    host: host,
    appId: appId,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );
}
