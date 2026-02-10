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

Future<Map<String, dynamic>> updateChildProfileAPI({
  required String nickname,
}) async {
  final accessToken = await UserPrefs.getAccessToken();
  final token = accessToken?.trim() ?? '';
  if (token.isEmpty) {
    throw Exception('未登录');
  }

  final body = <String, dynamic>{'nickname': nickname};

  if (kDebugMode) {
    debugPrint('Update child profile request: nickname=$nickname');
  }

  final resp = await dioUtils.put(
    HttpConstants.childProfile,
    data: body,
    headers: <String, dynamic>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (kDebugMode) {
    debugPrint('Update child profile response data: $resp');
  }

  if (resp is Map) {
    return Map<String, dynamic>.from(resp);
  }
  throw Exception('更新个人信息失败：数据格式错误');
}

Future<List<Map<String, dynamic>>> getChildClassRankingAPI() async {
  final accessToken = await UserPrefs.getAccessToken();
  final token = accessToken?.trim() ?? '';
  if (token.isEmpty) {
    throw Exception('未登录');
  }

  if (kDebugMode) {
    debugPrint('Get child class ranking request');
  }

  final result = await dioUtils.get(
    HttpConstants.childClassRanking,
    headers: <String, dynamic>{
      'Authorization': 'Bearer $token',
    },
  );

  if (kDebugMode) {
    debugPrint('Get child class ranking response data: $result');
  }

  if (result is Map) {
    final data = Map<String, dynamic>.from(result);
    final topList = data['topList'];
    if (topList is List) {
      return topList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }
  throw Exception('获取班级排名失败：数据格式错误');
}
