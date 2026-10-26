import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';

// Cambiar esta paleta modifica todas las pantallas que usan el tema.
class AppTheme {
  static const colorPrincipal = Color(0xFFA0144B);
  static const colorFondo = Color(0xFFFFDEF0);
  static const colorTarjeta = Color(0xFFEF729F);
  static const colorVioleta = Color(0xFF7336AF);
  static const colorCasillaClara = Color(0xFFFFFBFE);
  static const colorCasillaRosa = Color(0xFFF8D7E2);

  // Un único esquema para puzzle, frente a frente y Wi-Fi.
  static const tablero = ChessboardColorScheme(
    lightSquare: colorCasillaClara,
    darkSquare: colorCasillaRosa,
    background: SolidColorChessboardBackground(
      lightSquare: colorCasillaClara,
      darkSquare: colorCasillaRosa,
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: colorCasillaClara,
      darkSquare: colorCasillaRosa,
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
      lightSquare: colorCasillaClara,
      darkSquare: colorCasillaRosa,
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x667336AF)),
    selected: HighlightDetails(solidColor: Color(0x99EF729F)),
    validMoves: Color(0x667336AF),
    validPremoves: Color(0x44A0144B),
  );

  static const colorTiraJugadas = Color(0xFFE1A5BA);
  static const colorErrores = Color.fromARGB(255, 238, 161, 161);
  static const textoErrores = Color.fromARGB(255, 63, 9, 20);
  static const colorPistas = Color.fromARGB(255, 245, 223, 155);
  static const textoPistas = Color(0xFF665000);

  static ThemeData get claro => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal).copyWith(
      primary: colorPrincipal,
      primaryContainer: const Color(0xFFF8B5CF),
      onPrimaryContainer: const Color(0xFF52112C),
      tertiary: colorVioleta,
      surface: const Color(0xFFFFF1F8),
    ),
    scaffoldBackgroundColor: colorFondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: colorFondo,
      foregroundColor: Color(0xFF321523),
      centerTitle: false,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: colorFondo,
      indicatorColor: Color(0xFFF8B5CF),
    ),
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
