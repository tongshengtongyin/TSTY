import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

String _yiRandomHex(int len) {
  final now = DateTime.now().microsecondsSinceEpoch;
  var x = now;
  const chars = '0123456789abcdef';
  final buf = StringBuffer();
  for (var i = 0; i < len; i++) {
    x = (x * 1103515245 + 12345) & 0x7fffffff;
    buf.write(chars[x % 16]);
  }
  return buf.toString();
}

class UserPrefs {
  static const _kLoggedIn = 'user.loggedIn';
  static const _kSelectedCharacter = 'user.selectedCharacter';
  static const _kSoundEnabled = 'user.soundEnabled';
  static const _kThemeIndex = 'user.themeIndex';
  static const _kFontSizeIndex = 'user.fontSizeIndex';

  static const _kAccessToken = 'auth.accessToken';
  static const _kRefreshToken = 'auth.refreshToken';

  static const _kChildProfileJson = 'child.profile.json';

  static const _kDeviceId = 'device.id';

  static const _kIseAuthorization = 'ise.authorization';
  static const _kIseDate = 'ise.date';
  static const _kIseHost = 'ise.host';
  static const _kIseAppId = 'ise.appId';
  static const _kIseTimestamp = 'ise.timestamp';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, value);
  }

  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedIn);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kAccessToken);
    return (s == null || s.trim().isEmpty) ? null : s.trim();
  }

  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, token.trim());
  }

  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kRefreshToken);
    return (s == null || s.trim().isEmpty) ? null : s.trim();
  }

  static Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRefreshToken, token.trim());
  }

  static Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRefreshToken);
  }

  static Future<Map<String, dynamic>?> getChildProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kChildProfileJson);
    final s = raw?.trim() ?? '';
    if (s.isEmpty) return null;
    try {
      final obj = jsonDecode(s);
      if (obj is Map) {
        return Map<String, dynamic>.from(obj);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> setChildProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kChildProfileJson, jsonEncode(profile));
  }

  static Future<void> clearChildProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kChildProfileJson);
  }

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kDeviceId);
    final s = existing?.trim() ?? '';
    if (s.isNotEmpty) return s;

    final id = 'dev_${DateTime.now().millisecondsSinceEpoch}_${_yiRandomHex(10)}';
    await prefs.setString(_kDeviceId, id);
    return id;
  }

  static Future<IseAuthCache?> getIseAuthCache() async {
    final prefs = await SharedPreferences.getInstance();
    final authorization = prefs.getString(_kIseAuthorization);
    final date = prefs.getString(_kIseDate);
    final host = prefs.getString(_kIseHost);
    final appId = prefs.getString(_kIseAppId);
    final ts = prefs.getInt(_kIseTimestamp);

    if (authorization == null ||
        authorization.trim().isEmpty ||
        date == null ||
        date.trim().isEmpty ||
        host == null ||
        host.trim().isEmpty ||
        appId == null ||
        appId.trim().isEmpty ||
        ts == null ||
        ts <= 0) {
      return null;
    }

    return IseAuthCache(
      authorization: authorization,
      date: date,
      host: host,
      appId: appId,
      timestamp: ts,
    );
  }

  static Future<void> setIseAuthCache(IseAuthCache cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kIseAuthorization, cache.authorization);
    await prefs.setString(_kIseDate, cache.date);
    await prefs.setString(_kIseHost, cache.host);
    await prefs.setString(_kIseAppId, cache.appId);
    await prefs.setInt(_kIseTimestamp, cache.timestamp);
  }

  static Future<void> clearIseAuthCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIseAuthorization);
    await prefs.remove(_kIseDate);
    await prefs.remove(_kIseHost);
    await prefs.remove(_kIseAppId);
    await prefs.remove(_kIseTimestamp);
  }

  /// 0 = girl, 1 = boy
  static Future<int?> getSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kSelectedCharacter);
  }

  /// 0 = girl, 1 = boy
  static Future<void> setSelectedCharacter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSelectedCharacter, value);
  }

  static Future<void> clearSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSelectedCharacter);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEnabled, value);
  }

  static Future<int> getThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kThemeIndex) ?? 0;
  }

  static Future<void> setThemeIndex(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeIndex, value);
  }

  static Future<int> getFontSizeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kFontSizeIndex) ?? 1;
  }

  static Future<void> setFontSizeIndex(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFontSizeIndex, value);
  }
}

class IseAuthCache {
  final String authorization;
  final String date;
  final String host;
  final String appId;
  final int timestamp;

  const IseAuthCache({
    required this.authorization,
    required this.date,
    required this.host,
    required this.appId,
    required this.timestamp,
  });
}
