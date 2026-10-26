import 'package:flutter/material.dart';

// Cambiar esta paleta modifica todas las pantallas que usan el tema.
class AppTheme {
  static const colorIntro = Color(0xFFF7A8B5);
  static const colorPrincipal = Color(0xFFAD3565);
  static const colorFondo = Color.fromARGB(255, 237, 206, 215);

  static const colorTiraJugadas = Color(0xFFE1A5BA);
  static const colorErrores = Color.fromARGB(255, 238, 161, 161);
  static const textoErrores = Color.fromARGB(255, 63, 9, 20);
  static const colorPistas = Color.fromARGB(255, 245, 223, 155);
  static const textoPistas = Color(0xFF665000);

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
