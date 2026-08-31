import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences {
  SettingsPreferences(this._preferences);

  final SharedPreferences _preferences;

  static const _themeKey = 'theme_mode';
  static const _currencyKey = 'currency';

  String get themeMode {
    return _preferences.getString(_themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String value) {
    return _preferences.setString(_themeKey, value);
  }

  String get currency {
    return _preferences.getString(_currencyKey) ?? 'PKR';
  }

  Future<void> setCurrency(String value) {
    return _preferences.setString(_currencyKey, value);
  }
}
