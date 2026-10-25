import 'package:flutter/material.dart';

// Cambiar esta paleta modifica todas las pantallas que usan el tema.
class AppTheme {
  static const colorPrincipal = Color(0xFFAD3565);
  static const colorFondo = Color(0xFFFFF5F8);

  static ThemeData get claro => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal),
    scaffoldBackgroundColor: colorFondo,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
