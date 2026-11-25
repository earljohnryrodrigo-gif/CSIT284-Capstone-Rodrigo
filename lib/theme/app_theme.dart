import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color seedColor = Color.fromARGB(255, 204, 161, 33);

  static const Color presentColor = Color(0xFF2E7D32);
  static const Color absentColor = Color(0xFFC62828);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor:  const Color.fromARGB(255, 45, 165, 174),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );
  }
}