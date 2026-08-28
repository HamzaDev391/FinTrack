import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seedColor = Color(0xFF4F46E5);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FC),
  );
}
