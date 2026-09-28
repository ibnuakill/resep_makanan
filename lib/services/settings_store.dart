import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan preferensi pengguna ke SharedPreferences.
class SettingsStore {
  const SettingsStore();

  static const _kLang = 'pref_language';

  /// Bahasa default: 'id' (Indonesia). Pilihan lain: 'en' (English).
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLang) ?? 'id';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, code);
  }
}
