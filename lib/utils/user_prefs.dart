import 'package:tsty_app/components/ai_chat/ai_chat_models.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsty_app/api/tts.dart';

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
  static const _kSelectedAvatarIndex = 'user.selectedAvatarIndex';
  static const _kSoundEnabled = 'user.soundEnabled';
  static const _kThemeIndex = 'user.themeIndex';
  static const _kFontSizeIndex = 'user.fontSizeIndex';

  static const _kAccessToken = 'auth.accessToken';
  static const _kRefreshToken = 'auth.refreshToken';
  static const _kTokenExpiresIn = 'auth.tokenExpiresIn';
  static const _kTokenObtainedAtMs = 'auth.tokenObtainedAtMs';

  static const _kChildProfileJson = 'child.profile.json';

  static const _kDeviceId = 'device.id';

  static const _kIseAuthorization = 'ise.authorization';
  static const _kIseDate = 'ise.date';
  static const _kIseHost = 'ise.host';
  static const _kIseAppId = 'ise.appId';
  static const _kIseTimestamp = 'ise.timestamp';

  static const _kTtsAuthorization = 'tts.authorization';
  static const _kTtsDate = 'tts.date';
  static const _kTtsHost = 'tts.host';
  static const _kTtsAppId = 'tts.appId';
  static const _kTtsTimestamp = 'tts.timestamp';

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

  static Future<int?> getTokenExpiresInSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kTokenExpiresIn);
    return (v == null || v <= 0) ? null : v;
  }

  static Future<int?> getTokenObtainedAtMs() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kTokenObtainedAtMs);
    return (v == null || v <= 0) ? null : v;
  }

  static Future<void> setTokenMeta({
    required int tokenExpiresInSeconds,
    int? obtainedAtMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTokenExpiresIn, tokenExpiresInSeconds);
    await prefs.setInt(
      _kTokenObtainedAtMs,
      obtainedAtMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> clearTokenMeta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenExpiresIn);
    await prefs.remove(_kTokenObtainedAtMs);
  }

  static Future<bool> isAccessTokenExpiringSoon({
    Duration advance = const Duration(minutes: 5),
  }) async {
    final expiresIn = await getTokenExpiresInSeconds();
    final obtainedAtMs = await getTokenObtainedAtMs();
    if (expiresIn == null || obtainedAtMs == null) return false;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final expireAtMs = obtainedAtMs + expiresIn * 1000;
    return nowMs + advance.inMilliseconds >= expireAtMs;
  }

  static Future<void> setTokenBundle({
    required String accessToken,
    required String refreshToken,
    required int tokenExpiresInSeconds,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
    await setTokenMeta(tokenExpiresInSeconds: tokenExpiresInSeconds);
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

  static Future<TtsAuthCache?> getTtsAuthCache() async {
    final prefs = await SharedPreferences.getInstance();
    final authorization = prefs.getString(_kTtsAuthorization);
    final date = prefs.getString(_kTtsDate);
    final host = prefs.getString(_kTtsHost);
    final appId = prefs.getString(_kTtsAppId);
    final serviceType = prefs.getString('tts.serviceType');
    final ts = prefs.getInt(_kTtsTimestamp);

    if (authorization == null ||
        authorization.trim().isEmpty ||
        date == null ||
        date.trim().isEmpty ||
        host == null ||
        host.trim().isEmpty ||
        appId == null ||
        appId.trim().isEmpty ||
        serviceType == null ||
        serviceType.trim().isEmpty ||
        ts == null ||
        ts <= 0) {
      return null;
    }

    return TtsAuthCache(
      authorization: authorization,
      date: date,
      host: host,
      appId: appId,
      serviceType: serviceType,
      timestamp: ts,
    );
  }

  static Future<void> setTtsAuthCache(TtsAuthCache cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTtsAuthorization, cache.authorization);
    await prefs.setString(_kTtsDate, cache.date);
    await prefs.setString(_kTtsHost, cache.host);
    await prefs.setString(_kTtsAppId, cache.appId);
    await prefs.setString('tts.serviceType', cache.serviceType);
    await prefs.setInt(_kTtsTimestamp, cache.timestamp);
  }

  static Future<void> clearTtsAuthCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTtsAuthorization);
    await prefs.remove(_kTtsDate);
    await prefs.remove(_kTtsHost);
    await prefs.remove(_kTtsAppId);
    await prefs.remove('tts.serviceType');
    await prefs.remove(_kTtsTimestamp);
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

  static Future<int> getSelectedAvatarIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kSelectedAvatarIndex);
    return v ?? 0;
  }

  static Future<void> setSelectedAvatarIndex(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSelectedAvatarIndex, value);
  }

  static Future<void> clearSelectedAvatarIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSelectedAvatarIndex);
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

  static const _kRecentChatsJson = 'ai.recentChats.json';

  static Future<List<AiChatRecentChat>> getRecentChats() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kRecentChatsJson) ?? '[]';
    try {
      final List<dynamic> list = jsonDecode(s);
      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        return AiChatRecentChat(
          id: map['id'] ?? '',
          title: map['title'] ?? '',
          timestamp: DateTime.parse(map['timestamp']),
          type: map['type'] ?? '',
          icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
          iconColor: Color(map['iconColor']),
          bgColor: Color(map['bgColor']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addRecentChat(AiChatRecentChat chat) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecentChats();
    
    // Remove if already exists with same type (keep only latest of same type if desired, 
    // but here we just follow "last 5" rule)
    list.insert(0, chat);
    
    // Keep only 5
    if (list.length > 5) {
      list.removeRange(5, list.length);
    }

    final jsonList = list.map((item) => {
      'id': item.id,
      'title': item.title,
      'timestamp': item.timestamp.toIso8601String(),
      'type': item.type,
      'icon': item.icon.codePoint,
      'iconColor': item.iconColor.toARGB32(),
      'bgColor': item.bgColor.toARGB32(),
    }).toList();

    await prefs.setString(_kRecentChatsJson, jsonEncode(jsonList));
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
