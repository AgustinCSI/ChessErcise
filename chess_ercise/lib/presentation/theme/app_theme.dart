import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';

// Cambiar esta paleta modifica todas las pantallas que usan el tema.
class AppTheme {
  static const colorIntro = Color(0xFFF7A8B5);
  static const colorPrincipal = Color(0xFFA0144B);
  static const colorFondo = Color(0xFFFFDEF0);
  static const colorTarjeta = Color(0xFFEF729F);
  static const colorVioleta = Color(0xFF7336AF);
  static const colorCasillaClara = Color(0xFFFFFBFE);
  static const colorCasillaRosa = Color(0xFFF8D7E2);
  static const colorTexto = Color(0xFF24151E);
  static const colorTextoSecundario = Color(0xFF49313E);
  static const colorAceptar = Color(0xFF087F52);
  static const colorRechazar = Color(0xFFC4123D);
  static const colorBarra = Color(0xFFFFF1F8);
  static const colorBordeBarra = Color(0xFFE4A1BD);

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
      onPrimaryContainer: colorTexto,
      onSurface: colorTexto,
      onSurfaceVariant: colorTextoSecundario,
      tertiary: colorVioleta,
      surface: const Color(0xFFFFF1F8),
    ),
    scaffoldBackgroundColor: colorFondo,
    dividerColor: colorBordeBarra,
    textTheme: Typography.material2021().black.apply(
      bodyColor: colorTexto,
      displayColor: colorTexto,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: colorBarra,
      foregroundColor: colorTexto,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: colorBordeBarra)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorBarra,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 76,
      indicatorColor: colorPrincipal,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? Colors.white
              : colorTexto,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? colorPrincipal
              : colorTexto,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          fontSize: 12,
        ),
      ),
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
