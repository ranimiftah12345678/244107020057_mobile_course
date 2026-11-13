import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepository {
  static const _keyDarkMode = 'dark_mode';
  static const _keyLastOpened = 'last_opened_at';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<DateTime?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastOpened);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> updateLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOpened, DateTime.now().toIso8601String());
  }
}
