import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_ercise/data/lichess_puzzles_service.dart';
import 'package:chess_ercise/logic/puzzle_controller.dart';
import 'package:chess_ercise/models/progreso_puzzle.dart';
import 'package:chess_ercise/models/puzzle_diario.dart';
import 'package:chess_ercise/presentation/providers/puzzles_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:chess_ercise/presentation/screens/puzzles/puzzle_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

PuzzleDiario puzzle() => PuzzleDiario.fromJson(
  jsonDecode(io.File('test/fixtures/daily_puzzle.json').readAsStringSync())
      as Map<String, dynamic>,
);

class CountingService extends LichessPuzzlesService {
  int calls = 0;
  bool falla = false;
  @override
  Future<PuzzleDiario> obtenerDiario({CancelToken? cancelToken}) async {
    calls++;
    if (falla) throw const FormatException();
    return puzzle();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Prefetch and opening reuse one request; restart reads disk cache',
    () async {
      final service = CountingService();
      final provider = PuzzlesProvider(userId: 'A', service: service);
      provider.precargar();
      final first = provider.obtenerDiario();
      expect(provider.obtenerDiario(), same(first));
      final loaded = await first;
      expect(service.calls, 1);
      provider.dispose();
      final offline = CountingService()..falla = true;
      final reopened = PuzzlesProvider(userId: 'A', service: offline);
      expect((await reopened.obtenerDiario()).rating, loaded.rating);
      expect(offline.calls, 0);
      reopened.dispose();
    },
  );

  test(
    'Progress survives provider recreation and stays separate by user',
    () async {
      final provider = PuzzlesProvider(userId: 'A', service: CountingService());
      final loaded = await provider.obtenerDiario();
      await provider.guardar(
        loaded,
        const ProgresoPuzzle(indice: 1, errores: 3, pistas: {0}),
      );
      provider.dispose();
      final reopened = PuzzlesProvider(userId: 'A', service: CountingService());
      await reopened.obtenerDiario();
      final controller = PuzzleController(
        loaded,
        progreso: reopened.progresoPara(loaded),
      );
      // Complete a pending opponent response on restore, without another player move.
      expect(controller.indice, 2);
      expect(controller.errores, 3);
      expect(controller.pistasUsadas, 1);
      controller.dispose();
      final other = PuzzlesProvider(userId: 'B', service: CountingService());
      await other.obtenerDiario();
      expect(other.progresoPara(loaded).indice, 0);
      expect(other.progresoPara(loaded).errores, 0);
      other.dispose();
      reopened.dispose();
    },
  );

  test(
    'Terminal result cannot be overwritten, including after cache day rollover',
    () async {
      var now = DateTime.utc(2026, 10, 25, 23, 59);
      final service = CountingService();
      final provider = PuzzlesProvider(
        userId: 'A',
        service: service,
        ahora: () => now,
      );
      final loaded = await provider.obtenerDiario();
      await provider.guardar(
        loaded,
        ProgresoPuzzle(indice: loaded.solucion.length, errores: 2, pistas: {0}),
      );
      await provider.guardar(loaded, const ProgresoPuzzle());
      now = now.add(const Duration(minutes: 2));
      await provider.obtenerDiario();
      expect(service.calls, 2);
      expect(provider.progresoPara(loaded).indice, loaded.solucion.length);
      provider.dispose();
      final reopened = PuzzlesProvider(
        userId: 'A',
        service: CountingService(),
        ahora: () => now,
      );
      await reopened.obtenerDiario();
      final restored = PuzzleController(
        loaded,
        progreso: reopened.progresoPara(loaded),
      );
      expect(restored.completado, isTrue);
      expect(restored.completado, isTrue);
      expect(restored.errores, 2);
      restored.dispose();
      reopened.dispose();
    },
  );

  testWidgets('Reopening finished attempt shows summary and read-only review', (
    tester,
  ) async {
    final provider = PuzzlesProvider(userId: 'A', service: CountingService());
    final loaded = await provider.obtenerDiario();
    await provider.guardar(
      loaded,
      ProgresoPuzzle(indice: loaded.solucion.length, errores: 2, pistas: {0}),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleScreen(puzzle: loaded, diario: provider),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Resumen diario'), findsOneWidget);
    expect(find.text('¡Puzzle resuelto!'), findsOneWidget);
    expect(find.text('Errores: 2'), findsOneWidget);
    expect(find.text('Pistas usadas: 1'), findsOneWidget);
    await tester.tap(find.text('Revisar tablero'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Volver a intentarlo'), findsNothing);
    await tester.tap(find.byTooltip('Ver resumen'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen diario'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  test('Queued writes retain latest state; corrupted progress is not silently reset', () async {
    final provider = PuzzlesProvider(userId: 'A', service: CountingService());
    final loaded = await provider.obtenerDiario();
    provider.guardar(loaded, const ProgresoPuzzle(errores: 1));
    provider.guardar(loaded, const ProgresoPuzzle(errores: 2));
    await provider.guardar(
      loaded,
      const ProgresoPuzzle(errores: 3, rendido: true),
    );
    provider.dispose();
    final reopened = PuzzlesProvider(userId: 'A', service: CountingService());
    await reopened.obtenerDiario();
    expect(reopened.progresoPara(loaded).errores, 3);
    expect(reopened.progresoPara(loaded).rendido, isTrue);
    reopened.dispose();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chessercise.v1.A.progress.${loaded.id}', '{broken');
    final broken = PuzzlesProvider(userId: 'A', service: CountingService());
    await expectLater(broken.obtenerDiario(), throwsFormatException);
    broken.dispose();
  });

  test('Surrender and hints restore; repeated hints count once per step', () {
    final loaded = puzzle();
    final controller = PuzzleController(loaded);
    controller.mostrarPista();
    controller.mostrarPista();
    expect(controller.pistasUsadas, 1);
    controller.rendirse();
    final json = jsonDecode(
      jsonEncode(controller.estadoGuardado.toJson()),
    ) as Map<String, dynamic>;
    final restored = PuzzleController(
      loaded,
      progreso: ProgresoPuzzle.fromJson(json, loaded.solucion.length),
    );
    expect(restored.rendido, isTrue);
    expect(restored.completado, isFalse);
    expect(restored.pistasUsadas, 1);
    expect(restored.puedeMover, isFalse);
    expect(restored.totalJugadas, loaded.solucion.length);
    restored.dispose();
    controller.dispose();
  });

  test(
    'Failed prefetch can retry without an unhandled asynchronous error',
    () async {
      final service = CountingService()..falla = true;
      final provider = PuzzlesProvider(userId: 'A', service: service);
      provider.precargar();
      await expectLater(provider.obtenerDiario(), throwsFormatException);
      service.falla = false;
      expect((await provider.obtenerDiario()).id, puzzle().id);
      expect(service.calls, 2);
      provider.dispose();
    },
  );
}
