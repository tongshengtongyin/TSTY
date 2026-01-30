import 'package:shared_preferences/shared_preferences.dart';

class ParentCenterPrefs {
  static const _kParentLoggedIn = 'parentLoggedIn';

  static const _kDailyLimitMinutes = 'parentControl.dailyLimitMinutes';
  static const _kTimeEnabled = 'parentControl.timeEnabled';
  static const _kStartTime = 'parentControl.startTime';
  static const _kEndTime = 'parentControl.endTime';
  static const _kRestEnabled = 'parentControl.restEnabled';
  static const _kRestIntervalMinutes = 'parentControl.restIntervalMinutes';

  static Future<bool> isParentLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kParentLoggedIn) ?? false;
  }

  static Future<void> setParentLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kParentLoggedIn, value);
  }

  static Future<void> clearParentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kParentLoggedIn);
  }

  static Future<ParentControlSettings> getControlSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ParentControlSettings(
      dailyLimitMinutes: prefs.getInt(_kDailyLimitMinutes) ?? 30,
      timeEnabled: prefs.getBool(_kTimeEnabled) ?? true,
      startTime: prefs.getString(_kStartTime) ?? '18:00',
      endTime: prefs.getString(_kEndTime) ?? '20:00',
      restEnabled: prefs.getBool(_kRestEnabled) ?? true,
      restIntervalMinutes: prefs.getInt(_kRestIntervalMinutes) ?? 15,
    );
  }

  static Future<void> setControlSettings(ParentControlSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDailyLimitMinutes, settings.dailyLimitMinutes);
    await prefs.setBool(_kTimeEnabled, settings.timeEnabled);
    await prefs.setString(_kStartTime, settings.startTime);
    await prefs.setString(_kEndTime, settings.endTime);
    await prefs.setBool(_kRestEnabled, settings.restEnabled);
    await prefs.setInt(_kRestIntervalMinutes, settings.restIntervalMinutes);
  }
}

class ParentControlSettings {
  final int dailyLimitMinutes;
  final bool timeEnabled;
  final String startTime;
  final String endTime;
  final bool restEnabled;
  final int restIntervalMinutes;

  const ParentControlSettings({
    required this.dailyLimitMinutes,
    required this.timeEnabled,
    required this.startTime,
    required this.endTime,
    required this.restEnabled,
    required this.restIntervalMinutes,
  });

  ParentControlSettings copyWith({
    int? dailyLimitMinutes,
    bool? timeEnabled,
    String? startTime,
    String? endTime,
    bool? restEnabled,
    int? restIntervalMinutes,
  }) {
    return ParentControlSettings(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      timeEnabled: timeEnabled ?? this.timeEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      restEnabled: restEnabled ?? this.restEnabled,
      restIntervalMinutes: restIntervalMinutes ?? this.restIntervalMinutes,
    );
  }
}
