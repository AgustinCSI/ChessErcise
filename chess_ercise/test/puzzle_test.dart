import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_ercise/logic/puzzle_controller.dart';
import 'package:chess_ercise/models/puzzle_diario.dart';
import 'package:chess_ercise/presentation/screens/puzzles/puzzle_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(io.File('test/fixtures/daily_puzzle.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('Real response and PGN fallback give the same board and turn', () {
    final json = fixture();
    final fenPuzzle = PuzzleDiario.fromJson(json);
    (json['puzzle'] as Map).remove('fen');
    final pgnPuzzle = PuzzleDiario.fromJson(json);
    expect(pgnPuzzle.posicionInicial.board, fenPuzzle.posicionInicial.board);
    expect(pgnPuzzle.posicionInicial.turn, Side.black);
    expect(pgnPuzzle.ultimaJugada?.uci, 'g2f2');
    expect(pgnPuzzle.posicionInicial.isLegal(pgnPuzzle.solucion.first), isTrue);
  });

  test('Malformed, empty and illegal solutions are rejected', () {
    expect(() => PuzzleDiario.fromJson({}), throwsFormatException);
    for (final solution in [
      [],
      ['x'],
      ['a1a8'],
    ]) {
      final json = fixture();
      (json['puzzle'] as Map)['solution'] = solution;
      expect(() => PuzzleDiario.fromJson(json), throwsFormatException);
    }
  });

  testWidgets(
    'Wrong move preserves position; full sequence solves and locks board',
    (tester) async {
      final puzzle = PuzzleDiario.fromJson(fixture());
      final controller = PuzzleController(puzzle);
      final start = controller.posicion.fen;
      controller.jugar(Move.parse('h3g3')!);
      expect(controller.errores, 1);
      expect(controller.posicion.fen, start);
      controller.jugar(puzzle.solucion[0]);
      expect(controller.esperando, isTrue);
      controller.jugar(puzzle.solucion[2]);
      expect(controller.indice, 1);
      await tester.pump(const Duration(milliseconds: 650));
      expect(controller.indice, 2);
      expect(controller.esperando, isFalse);
      controller.jugar(puzzle.solucion[2]);
      expect(controller.completado, isTrue);
      expect(controller.posicion.isCheckmate, isTrue);
      expect(controller.puedeMover, isFalse);
      controller.reiniciar();
      expect(controller.posicion.fen, start);
      expect(controller.errores, 0);
      controller.dispose();
    },
  );

  testWidgets('Reset and disposal cancel pending opponent reply', (
    tester,
  ) async {
    final controller = PuzzleController(PuzzleDiario.fromJson(fixture()));
    controller.jugar(controller.puzzle.solucion.first);
    controller.reiniciar();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.indice, 0);
    controller.jugar(controller.puzzle.solucion.first);
    controller.dispose();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  test('Promotion and alternate castling notation are supported', () {
    final promotion = PuzzleDiario.fromJson({
      'puzzle': {
        'id': 'promotion',
        'rating': 1000,
        'fen': '7k/P7/8/8/8/8/8/7K w - - 0 1',
        'solution': ['a7a8q'],
      },
    });
    final controller = PuzzleController(promotion);
    controller.jugar(Move.parse('a7a8n')!);
    expect(controller.errores, 1);
    controller.jugar(Move.parse('a7a8q')!);
    expect(controller.completado, isTrue);
    controller.dispose();
    final castle = PuzzleDiario.fromJson({
      'puzzle': {
        'id': 'castle',
        'rating': 1000,
        'fen': '4k3/8/8/8/8/8/8/4K2R w K - 0 1',
        'solution': ['e1g1'],
      },
    });
    final castleController = PuzzleController(castle);
    castleController.jugar(Move.parse('e1h1')!);
    expect(castleController.completado, isTrue);
    castleController.dispose();
  });

  testWidgets('Board renders on a small phone and landscape without overflow', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(740, 360)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: PuzzleScreen(
            key: ValueKey(size),
            puzzle: PuzzleDiario.fromJson(fixture()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Juegas con negras'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
