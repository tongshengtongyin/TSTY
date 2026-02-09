import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

Future<Map<String, dynamic>> getChildProfileAPI() async {
  final accessToken = await UserPrefs.getAccessToken();
  final token = accessToken?.trim() ?? '';
  if (token.isEmpty) {
    throw Exception('未登录');
  }

  if (kDebugMode) {
    debugPrint('Get child profile request');
  }

  final result = await dioUtils.get(
    HttpConstants.childProfile,
    headers: <String, dynamic>{
      'Authorization': 'Bearer $token',
    },
  );

  if (kDebugMode) {
    debugPrint('Get child profile response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  throw Exception('获取个人信息失败：数据格式错误');
}
