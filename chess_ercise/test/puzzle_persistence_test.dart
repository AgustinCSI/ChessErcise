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
  PuzzleDiario? respuesta;
  @override
  Future<PuzzleDiario> obtenerDiario({CancelToken? cancelToken}) async {
    calls++;
    if (falla) throw const FormatException();
    return respuesta ?? puzzle();
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
    'Daily refresh expires within the same UTC day without resetting results',
    () async {
      var now = DateTime.utc(2026, 10, 26, 0, 1);
      final service = CountingService();
      final provider = PuzzlesProvider(
        userId: 'A',
        service: service,
        ahora: () => now,
      );
      final previous = await provider.obtenerDiario();
      await provider.guardar(
        previous,
        ProgresoPuzzle(indice: previous.solucion.length, errores: 2),
      );
      now = now.add(const Duration(minutes: 14));
      await provider.obtenerDiario();
      expect(service.calls, 1);
      final json = previous.toJson();
      (json['puzzle'] as Map<String, dynamic>)['id'] = 'new-daily';
      service.respuesta = PuzzleDiario.fromJson(json);
      now = now.add(const Duration(minutes: 1));
      final current = await provider.obtenerDiario();
      expect(service.calls, 2);
      expect(current.id, 'new-daily');
      expect(provider.progresoPara(current).indice, 0);
      expect(provider.progresoPara(previous).errores, 2);
      // Explicit refresh also reaches Lichess while the cache is still fresh.
      await provider.obtenerDiario(actualizar: true);
      expect(service.calls, 3);
      provider.dispose();
    },
  );

  test('Disk cache expiry does not slide forward on every restart', () async {
    var now = DateTime.utc(2026, 10, 26, 4);
    PuzzlesProvider create(CountingService service) =>
        PuzzlesProvider(userId: 'A', service: service, ahora: () => now);
    final first = create(CountingService());
    await first.obtenerDiario();
    first.dispose();
    now = now.add(const Duration(minutes: 14));
    final service = CountingService();
    final reopened = create(service);
    await reopened.obtenerDiario();
    expect(service.calls, 0);
    now = now.add(const Duration(minutes: 1));
    await reopened.obtenerDiario();
    expect(service.calls, 1);
    reopened.dispose();
  });

  test('Legacy cache is revalidated and refresh failures can retry', () async {
    final now = DateTime.utc(2026, 10, 26, 4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'chessercise.v1.A.daily',
      jsonEncode({'dia': '2026-10-26', 'puzzle': puzzle().toJson()}),
    );
    final service = CountingService()..falla = true;
    final provider = PuzzlesProvider(
      userId: 'A',
      service: service,
      ahora: () => now,
    );
    await expectLater(provider.obtenerDiario(), throwsFormatException);
    expect(service.calls, 1);
    service.falla = false;
    await provider.obtenerDiario();
    expect(service.calls, 2);
    service.falla = true;
    await expectLater(
      provider.obtenerDiario(actualizar: true),
      throwsFormatException,
    );
    service.falla = false;
    await provider.obtenerDiario(actualizar: true);
    expect(service.calls, 4);
    provider.dispose();
  });

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
    expect(find.text('12 repeticiones en total'), findsOneWidget);
    await tester.ensureVisible(find.text('Revisar tablero'));
    await tester.tap(find.text('Revisar tablero'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Volver a intentarlo'), findsNothing);
    await tester.tap(find.byTooltip('Ver resumen'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen diario'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  test('Routine completion survives restart without changing the sealed result', () async {
    final provider = PuzzlesProvider(userId: 'A', service: CountingService());
    final loaded = await provider.obtenerDiario();
    // An unfinished puzzle cannot acquire a routine.
    await provider.guardarRutina(loaded, 'flexiones', completada: true);
    expect(provider.progresoPara(loaded).rutinaCompletada, isFalse);
    await provider.guardar(
      loaded,
      ProgresoPuzzle(indice: loaded.solucion.length, errores: 2, pistas: {0}),
    );
    await provider.guardarRutina(loaded, 'plancha-frontal');
    expect(provider.progresoPara(loaded).ejercicioId, 'sentadillas');
    await provider.guardarRutina(loaded, 'flexiones', completada: true);
    // Stale controller writes or another confirmation cannot reset the routine.
    await provider.guardar(loaded, const ProgresoPuzzle());
    await provider.guardarRutina(loaded, 'zancadas');
    provider.dispose();
    final reopened = PuzzlesProvider(userId: 'A', service: CountingService());
    await reopened.obtenerDiario();
    final saved = reopened.progresoPara(loaded);
    expect(saved.indice, loaded.solucion.length);
    expect(saved.errores, 2);
    expect(saved.pistas, {0});
    expect(saved.repeticiones, 12);
    expect(saved.ejercicioId, 'flexiones');
    expect(saved.rutinaCompletada, isTrue);
    final other = PuzzlesProvider(userId: 'B', service: CountingService());
    await other.obtenerDiario();
    expect(other.progresoPara(loaded).rutinaCompletada, isFalse);
    other.dispose();
    reopened.dispose();
  });

  test(
    'Old saves, zero penalties and surrender use the same repetition rule',
    () async {
      final loaded = puzzle();
      final old = ProgresoPuzzle.fromJson({
        'indice': loaded.solucion.length,
        'errores': 0,
        'pistas': <int>[],
        'rendido': false,
      }, loaded.solucion.length);
      expect(old.repeticiones, 0);
      expect(old.ejercicioId, 'sentadillas');
      expect(old.rutinaCompletada, isFalse);
      final provider = PuzzlesProvider(userId: 'A', service: CountingService());
      await provider.obtenerDiario();
      await provider.guardar(
        loaded,
        const ProgresoPuzzle(errores: 1, pistas: {0}, rendido: true),
      );
      await provider.guardarRutina(loaded, 'zancadas', completada: true);
      final saved = provider.progresoPara(loaded);
      expect(saved.repeticiones, 7);
      expect(saved.rendido, isTrue);
      expect(saved.rutinaCompletada, isTrue);
      expect(
        ProgresoPuzzle.fromJson(
          saved.toJson(),
          loaded.solucion.length,
        ).ejercicioId,
        'zancadas',
      );
      provider.dispose();
    },
  );

  testWidgets('Summary lets the player choose and confirm the saved routine', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = PuzzlesProvider(userId: 'A', service: CountingService());
    final loaded = await provider.obtenerDiario();
    await provider.guardar(
      loaded,
      ProgresoPuzzle(indice: loaded.solucion.length, errores: 1, pistas: {0}),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleScreen(puzzle: loaded, diario: provider),
      ),
    );
    await tester.pumpAndSettle();
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flexiones de brazos').last);
    await tester.pumpAndSettle();
    expect(provider.progresoPara(loaded).ejercicioId, 'flexiones');
    await tester.ensureVisible(find.text('Listo'));
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(find.text('Rutina completada'), findsOneWidget);
    expect(find.text('Listo'), findsNothing);
    expect(find.text('7 repeticiones en total'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
