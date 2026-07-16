import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

Future<Map<String, dynamic>> getParentReportOverviewAPI({
  String period = 'week',
  String? accessToken,
}) async {
  final token = (accessToken == null || accessToken.trim().isEmpty)
      ? await UserPrefs.getAccessToken()
      : accessToken.trim();

  final headers = (token == null || token.isEmpty)
      ? null
      : <String, dynamic>{'Authorization': 'Bearer $token'};

  if (kDebugMode) {
    debugPrint(
      'Parent report overview request: ${HttpConstants.parentReportOverview} '
      'period=$period authHeader=${headers == null ? 'none' : 'bearer'}',
    );
  }

  final result = await dioUtils.get(
    HttpConstants.parentReportOverview,
    params: <String, dynamic>{'period': period},
    headers: headers,
  );

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }

  throw Exception('学习报告数据格式错误');
}
