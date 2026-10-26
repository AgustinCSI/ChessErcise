import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_ercise/data/lichess_puzzles_service.dart';
import 'package:chess_ercise/models/puzzle_diario.dart';
import 'package:chess_ercise/presentation/providers/puzzles_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_ercise/presentation/screens/puzzles/daily_puzzle_screen.dart';
import 'package:chess_ercise/presentation/screens/puzzles/puzzle_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledService extends LichessPuzzlesService {
  int calls = 0;
  Completer<PuzzleDiario> response = Completer();

  @override
  Future<PuzzleDiario> obtenerDiario({CancelToken? cancelToken}) {
    calls++;
    return response.future;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Loading, error, retry and navigation reuse one fetched puzzle', (
    tester,
  ) async {
    final service = ControlledService();
    final diario = PuzzlesProvider(userId: 'test', service: service);
    await tester.pumpWidget(
      MaterialApp(home: DailyPuzzleScreen(diario: diario)),
    );
    expect(find.text('Cargando el puzzle de Lichess…'), findsOneWidget);
    await tester.pump();
    expect(service.calls, 1);
    service.response.completeError(const FormatException());
    await tester.pumpAndSettle();
    expect(
      find.text('El puzzle recibido no se pudo interpretar.'),
      findsOneWidget,
    );
    service.response = Completer();
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(service.calls, 2);
    final puzzle = PuzzleDiario.fromJson(
      jsonDecode(io.File('test/fixtures/daily_puzzle.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    service.response.complete(puzzle);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolver puzzle'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PuzzleScreen>(find.byType(PuzzleScreen)).puzzle,
      same(puzzle),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(service.calls, 2);
    service.response = Completer();
    await tester.tap(find.byTooltip('Actualizar puzzle'));
    await tester.pump();
    expect(service.calls, 3);
    expect(find.text('Cargando el puzzle de Lichess…'), findsOneWidget);
    service.response.complete(puzzle);
    await tester.pumpAndSettle();
    expect(find.text('Resolver puzzle'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    diario.dispose();
  });
}
