import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';

String md5Hex(String input) {
  final bytes = utf8.encode(input);
  return md5.convert(bytes).toString();
}

Future<Map<String, dynamic>> childLoginPasswordAPI({
  required String username,
  required String passwordMd5,
  required String deviceId,
  required String deviceType,
}) async {
  final body = <String, dynamic>{
    'username': username,
    'password': passwordMd5,
    'deviceId': deviceId,
    'deviceType': deviceType,
  };

  if (kDebugMode) {
    debugPrint('Child login-password request: username=$username deviceId=$deviceId deviceType=$deviceType');
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
