import 'dart:async';

import 'package:chess_ercise/app.dart';
import 'package:chess_ercise/presentation/screens/intro/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Los códecs de imagen usan el reloj real del motor, no el reloj falso de pump.
Future<void> cargarIntro(WidgetTester tester) async {
  for (var i = 0; i < 100 && tester.binding.transientCallbackCount == 0; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  expect(tester.binding.transientCallbackCount, greaterThan(0));
  await tester.pump();
}

void main() {
  testWidgets(
    'Startup shows intro once, then configuration; rebuild does not replay',
    (tester) async {
      await tester.pumpWidget(const ChessErciseApp(supabaseDisponible: false));
      await cargarIntro(tester);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.textContaining('SUPABASE_URL'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
      expect(find.byType(IntroScreen), findsNothing);
      await tester.pumpWidget(const ChessErciseApp(supabaseDisponible: false));
      await tester.pumpAndSettle();
      expect(find.byType(IntroScreen), findsNothing);
    },
  );

  testWidgets('Slow initialization waits after animation and handles failure', (
    tester,
  ) async {
    final ready = Completer<bool>();
    await tester.pumpWidget(ChessErciseApp(inicializacion: ready.future));
    await cargarIntro(tester);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('Preparando tu cuenta…'), findsOneWidget);
    ready.completeError(StateError('Initialization failed'));
    await tester.pumpAndSettle();
    expect(find.byType(IntroScreen), findsNothing);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion and short landscape fit; completion fires once', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(740, 360));
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: IntroScreen(onFinished: () => completed++),
        ),
      ),
    );
    await cargarIntro(tester);
    await tester.pump(const Duration(milliseconds: 250));
    expect(completed, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(completed, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
