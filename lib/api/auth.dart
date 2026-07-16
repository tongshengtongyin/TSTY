import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

String md5Hex(String input) {
  final bytes = utf8.encode(input);
  return md5.convert(bytes).toString();
}

Future<Map<String, dynamic>> childLoginPasswordAPI({
  required String username,
  required String password,
  required String deviceId,
  required String deviceType,
}) async {
  final body = <String, dynamic>{
    'username': username,
    'password': password,
    'deviceId': deviceId,
    'deviceType': deviceType,
  };

  if (kDebugMode) {
    debugPrint(
      'Child login-password request: username=$username deviceId=$deviceId deviceType=$deviceType',
    );
  }

  final result = await dioUtils.post(
    HttpConstants.childLoginPassword,
    data: body,
    headers: const <String, dynamic>{'Content-Type': 'application/json'},
  );

  if (kDebugMode) {
    debugPrint('Child login-password response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  throw Exception('登录响应数据格式错误');
}

class ParentLoginResponse {
  final String parentId;
  final String parentName;
  final String relationship;
  final bool forceChangePassword;

  ParentLoginResponse({
    required this.parentId,
    required this.parentName,
    required this.relationship,
    required this.forceChangePassword,
  });

  factory ParentLoginResponse.fromJson(Map<String, dynamic> json) {
    return ParentLoginResponse(
      parentId: json['parentId'] ?? '',
      parentName: json['parentName'] ?? '',
      relationship: json['relationship'] ?? '',
      forceChangePassword: json['forceChangePassword'] ?? false,
    );
  }
}

Future<ParentLoginResponse> parentLoginAPI({required String password}) async {
  final body = <String, dynamic>{'password': password};

  if (kDebugMode) {
    debugPrint('Parent login request');
  }

  final result = await dioUtils.post(
    HttpConstants.parentLogin,
    data: body,
    options: Options(contentType: 'application/json; charset=utf-8'),
  );

  if (kDebugMode) {
    debugPrint('Parent login response data: $result');
  }

  if (result is Map) {
    return ParentLoginResponse.fromJson(Map<String, dynamic>.from(result));
  }
  throw Exception('家长验证失败：响应数据格式错误');
}

Future<void> parentChangePasswordAPI({
  required String oldPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  final body = <String, dynamic>{
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };

  if (kDebugMode) {
    debugPrint('Parent change password request');
  }

  await dioUtils.post(
    HttpConstants.parentChangePassword,
    data: body,
    options: Options(contentType: 'application/json; charset=utf-8'),
  );
}

Future<Map<String, dynamic>> changePasswordAPI({
  required String oldPasswordMd5,
  required String newPasswordMd5,
  required String confirmPasswordMd5,
}) async {
  final accessToken = await UserPrefs.getAccessToken();
  final token = accessToken?.trim() ?? '';
  if (token.isEmpty) {
    throw Exception('未登录');
  }

  final body = <String, dynamic>{
    'oldPassword': oldPasswordMd5,
    'newPassword': newPasswordMd5,
    'confirmPassword': confirmPasswordMd5,
  };

  if (kDebugMode) {
    debugPrint('Change password request');
  }

  final result = await dioUtils.post(
    HttpConstants.changePassword,
    data: body,
    headers: <String, dynamic>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (kDebugMode) {
    debugPrint('Change password response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  return <String, dynamic>{};
}

Future<Map<String, dynamic>> refreshTokenAPI({
  required String refreshToken,
  required String deviceId,
}) async {
  final body = <String, dynamic>{
    'refreshToken': refreshToken,
    'deviceId': deviceId,
  };

  if (kDebugMode) {
    debugPrint('Auth refresh request: deviceId=$deviceId');
  }

  final result = await dioUtils.post(
    HttpConstants.authRefresh,
    data: body,
    headers: const <String, dynamic>{'Content-Type': 'application/json'},
  );

  if (kDebugMode) {
    debugPrint('Auth refresh response data: $result');
  }

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }
  throw Exception('刷新Token失败：数据格式错误');
}

Future<void> logoutAPI() async {
  final accessToken = await UserPrefs.getAccessToken();
  final token = accessToken?.trim() ?? '';
  if (token.isEmpty) return;

  if (kDebugMode) {
    debugPrint('Auth logout request');
  }

  await dioUtils.post(
    HttpConstants.authLogout,
    data: const <String, dynamic>{},
    headers: <String, dynamic>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}
