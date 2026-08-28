import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const seedColor = Color(0xFF4F46E5);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF101114),
  );
}
