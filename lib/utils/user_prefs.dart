import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _kLoggedIn = 'user.loggedIn';
  static const _kSelectedCharacter = 'user.selectedCharacter';
  static const _kSoundEnabled = 'user.soundEnabled';
  static const _kThemeIndex = 'user.themeIndex';
  static const _kFontSizeIndex = 'user.fontSizeIndex';

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
