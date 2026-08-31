import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final settingsPreferencesProvider = Provider<SettingsPreferences>((ref) {
  return SettingsPreferences(ref.watch(sharedPreferencesProvider));
});

final themeModeProvider = NotifierProvider<ThemeModeNotifier, String>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() {
    return ref.watch(settingsPreferencesProvider).themeMode;
  }

  Future<void> setThemeMode(String value) async {
    await ref.read(settingsPreferencesProvider).setThemeMode(value);
    state = value;
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    return ref.watch(settingsPreferencesProvider).currency;
  }

  Future<void> setCurrency(String value) async {
    await ref.read(settingsPreferencesProvider).setCurrency(value);
    state = value;
  }
}
