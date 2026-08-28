import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return buildLightTheme();
  }

  static ThemeData dark() {
    return buildDarkTheme();
  }
}
