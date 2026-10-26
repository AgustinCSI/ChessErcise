import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_ercise/logic/puzzle_controller.dart';
import 'package:chess_ercise/models/puzzle_diario.dart';
import 'package:chess_ercise/presentation/screens/puzzles/puzzle_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:chess_ercise/presentation/widgets/tablero_widget.dart';
import 'package:chess_ercise/presentation/widgets/player_info.dart';
import 'package:chess_ercise/presentation/widgets/puzzle_status.dart';
import 'package:chess_ercise/presentation/widgets/puzzle_moves.dart';
import 'package:chess_ercise/presentation/widgets/puzzle_toolbar.dart';
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
      expect(controller.completado, isTrue);
      expect(controller.errores, 1);
      controller.dispose();
    },
  );

  testWidgets('Disposal cancels pending opponent reply', (tester) async {
    final controller = PuzzleController(PuzzleDiario.fromJson(fixture()));
    controller.jugar(controller.puzzle.solucion.first);
    controller.dispose();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('History is read-only and retains last-move highlights', (
    tester,
  ) async {
    final controller = PuzzleController(PuzzleDiario.fromJson(fixture()));
    final start = controller.posicion.fen;
    controller.mostrarPista();
    expect(
      controller.pista,
      (controller.puzzle.solucion.first as NormalMove).from,
    );
    controller.jugar(controller.puzzle.solucion.first);
    expect(controller.pista, isNull);
    controller.anterior();
    expect(controller.posicionVisible.fen, start);
    expect(controller.jugadaVisible, controller.puzzle.ultimaJugada);
    expect(controller.puedeMover, isFalse);
    // A reply arriving while reviewing must not move the viewing cursor.
    await tester.pump(const Duration(milliseconds: 650));
    final live = controller.posicion.fen;
    expect(controller.vista, 0);
    expect(controller.indice, 2);
    controller.jugar(controller.puzzle.solucion.last);
    controller.mostrarPista();
    expect(controller.indice, 2);
    expect(controller.pista, isNull);
    controller.siguiente();
    expect(controller.jugadaVisible, controller.puzzle.solucion.first);
    expect(controller.puedeMover, isFalse);
    controller.siguiente();
    expect(controller.posicionVisible.fen, live);
    expect(controller.jugadaVisible, controller.puzzle.solucion[1]);
    expect(controller.puedeMover, isTrue);
    controller.jugar(controller.puzzle.solucion.last);
    expect(controller.completado, isTrue);
    controller.dispose();
  });

  testWidgets('Surrender cancels reply and reveals solution without success', (
    tester,
  ) async {
    final controller = PuzzleController(PuzzleDiario.fromJson(fixture()));
    controller.jugar(controller.puzzle.solucion.first);
    final live = controller.posicion.fen;
    controller.rendirse();
    controller.rendirse();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.indice, 1);
    expect(controller.posicion.fen, live);
    expect(controller.rendido, isTrue);
    expect(controller.completado, isFalse);
    expect(controller.totalJugadas, 3);
    controller.siguiente();
    controller.siguiente();
    expect(controller.posicionVisible.isCheckmate, isTrue);
    expect(controller.puedeMover, isFalse);
    expect(controller.rendido, isTrue);
    expect(controller.totalJugadas, 3);
    expect(controller.puedeMover, isFalse);
    controller.dispose();
  });

  testWidgets('Toolbar confirms surrender and keeps icon-only controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PuzzleScreen(puzzle: PuzzleDiario.fromJson(fixture())),
      ),
    );
    expect(find.byTooltip('Jugada anterior'), findsOneWidget);
    expect(find.byTooltip('Jugada siguiente'), findsOneWidget);
    await tester.tap(find.byTooltip('Pista: pieza que debes mover'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rendirse y ver solución'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Te rendiste.'), findsNothing);
    await tester.tap(find.byTooltip('Rendirse y ver solución'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver solución'));
    await tester.pumpAndSettle();
    expect(find.text('Te rendiste'), findsOneWidget);
    await tester.tap(find.text('Revisar tablero'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Te rendiste.'), findsOneWidget);
    await tester.tap(find.byTooltip('Jugada siguiente'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
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
    expect(controller.historial.single.san, 'a8=Q+');
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
    expect(castleController.historial.single.san, 'O-O');
    castleController.dispose();
  });

  testWidgets('SAN numbers black starts and only includes accepted moves', (
    tester,
  ) async {
    final controller = PuzzleController(PuzzleDiario.fromJson(fixture()));
    expect(controller.historial, isEmpty);
    controller.jugar(Move.parse('h3g3')!);
    expect(controller.historial, isEmpty);
    controller.jugar(controller.puzzle.solucion.first);
    expect(controller.historial.map((m) => m.san), ['Bxf2+']);
    expect(controller.historial.first.numero, 1);
    expect(controller.historial.first.lado, Side.black);
    await tester.pump(const Duration(milliseconds: 650));
    expect(controller.historial.map((m) => m.san), ['Bxf2+', 'Kxf2']);
    expect(controller.historial.last.numero, 2);
    final live = controller.posicion.fen;
    controller.irA(1);
    expect(controller.puedeMover, isFalse);
    expect(controller.posicion.fen, live);
    controller.irA(2);
    expect(controller.puedeMover, isTrue);
    controller.rendirse();
    expect(controller.historial.last.san, 'Qg3#');
    controller.dispose();
  });

  testWidgets('Tapping notation reviews without changing saved progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PuzzleScreen(puzzle: PuzzleDiario.fromJson(fixture())),
      ),
    );
    await tester.pumpAndSettle();
    final controller = tester
        .widget<TableroWidget>(find.byType(TableroWidget))
        .puzzle;
    controller.jugar(controller.puzzle.solucion.first);
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();
    final live = controller.posicion.fen;
    await tester.tap(find.byTooltip('1... Bxf2+'));
    await tester.pumpAndSettle();
    expect(controller.vista, 1);
    expect(controller.indice, 2);
    expect(controller.posicion.fen, live);
    expect(controller.puedeMover, isFalse);
    expect(find.byTooltip('2... Qg3#'), findsNothing);
    await tester.tap(find.byTooltip('2. Kxf2'));
    await tester.pumpAndSettle();
    expect(controller.puedeMover, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Move strip keeps fixed bounds and scrolls through a long line', (
    tester,
  ) async {
    final moves = <Move>[
      for (var i = 0; i < 3; i++) ...[
        Move.parse('g1f3')!,
        Move.parse('g8f6')!,
        Move.parse('f3g1')!,
        Move.parse('f6g8')!,
      ],
      Move.parse('g1f3')!,
    ];
    final controller = PuzzleController(
      PuzzleDiario(
        id: 'long',
        rating: 1000,
        posicionInicial: Chess.initial,
        solucion: moves,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 260,
              child: ListenableBuilder(
                listenable: controller,
                builder: (_, _) => PuzzleMoves(controller: controller),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final emptyBounds = tester.getRect(find.byType(PuzzleMoves));
    expect(emptyBounds.width, 260);
    expect(emptyBounds.height, 48);
    controller.rendirse();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(PuzzleMoves)), emptyBounds);
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.drag(find.byType(PuzzleMoves), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
    controller.irA(controller.totalJugadas);
    await tester.pumpAndSettle();
    final selected = tester.getRect(find.byTooltip('7. Nf3'));
    expect(selected.left, greaterThanOrEqualTo(emptyBounds.left));
    expect(selected.right, lessThanOrEqualTo(emptyBounds.right));
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('Review and completion messages keep board and player in place', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PuzzleScreen(puzzle: PuzzleDiario.fromJson(fixture())),
      ),
    );
    await tester.pumpAndSettle();
    final controller = tester
        .widget<TableroWidget>(find.byType(TableroWidget))
        .puzzle;
    controller.jugar(controller.puzzle.solucion.first);
    await tester.pump(const Duration(milliseconds: 650));
    controller.jugar(controller.puzzle.solucion.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisar tablero'));
    await tester.pumpAndSettle();
    final board = tester.getRect(find.byType(TableroWidget));
    final player = tester.getRect(find.byType(PlayerInfo));
    final status = tester.getRect(find.byType(PuzzleStatus));
    await tester.tap(find.byTooltip('Jugada anterior'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Revisando jugadas.'), findsOneWidget);
    expect(tester.getRect(find.byType(PuzzleStatus)), status);
    expect(tester.getRect(find.byType(TableroWidget)), board);
    expect(tester.getRect(find.byType(PlayerInfo)), player);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'Puzzle fits phone and desktop sizes without scrolling or clipping',
    (tester) async {
      for (final size in [
        const Size(320, 480),
        const Size(320, 640),
        const Size(390, 844),
        const Size(740, 360),
        const Size(1280, 720),
        const Size(1920, 1080),
      ]) {
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
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is SingleChildScrollView &&
                w.scrollDirection == Axis.vertical,
          ),
          findsNothing,
        );
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.textContaining('Jugada 0/'), findsNothing);
        final player = tester.getRect(find.byType(PlayerInfo));
        final counters = tester.getRect(
          find.byKey(const ValueKey('puzzle-counters')),
        );
        expect(counters.top, closeTo(player.bottom + 8, 0.01));
        expect(find.text('Errores: 0'), findsOneWidget);
        expect(find.text('Pistas: 0'), findsOneWidget);
        expect(
          counters.bottom,
          lessThanOrEqualTo(tester.getRect(find.byType(PuzzleToolbar)).top),
        );
        final board = tester.getRect(find.byType(TableroWidget));
        final toolbar = tester.getRect(find.byType(PuzzleToolbar));
        expect(find.byTooltip('Volver a intentarlo'), findsNothing);
        final strip = tester.getRect(find.byType(PuzzleMoves));
        expect(player.top, closeTo(board.bottom + 8, 0.01));
        expect(find.text('Tu nombre'), findsOneWidget);
        if (size.width < 600) {
          expect(
            strip.top,
            closeTo(tester.getRect(find.byType(PuzzleStatus)).bottom + 4, 0.01),
          );

          expect(
            tester.getRect(find.byType(PuzzleStatus)).bottom,
            lessThanOrEqualTo(board.top),
          );
        }
        expect(strip.left, closeTo(board.left, 0.01));
        expect(strip.right, closeTo(board.right, 0.01));
        if (size.width >= 1280) {
          final info = tester.getRect(find.byType(PuzzleStatus));
          expect(info.left - board.right, closeTo(24, 0.01));
          expect(board.width, lessThanOrEqualTo(560));
        }
        expect(board.width, greaterThan(0));
        expect(board.width, closeTo(board.height, 0.01));
        expect(board.bottom, lessThanOrEqualTo(toolbar.top));
        expect(strip.bottom, lessThanOrEqualTo(board.top));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );
}
