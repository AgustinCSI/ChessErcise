import 'dart:async';

import 'package:chess_ercise/app.dart';
import 'package:chess_ercise/data/perfil_service.dart';
import 'package:chess_ercise/models/perfil.dart';
import 'package:chess_ercise/presentation/providers/auth_provider.dart';
import 'package:chess_ercise/presentation/screens/profile/profile_gate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chess_ercise/presentation/screens/intro/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Los códecs de imagen usan el reloj real del motor, no el reloj falso de pump.
Future<void> cargarIntro(WidgetTester tester) async {
  bool introAnimando() => tester
      .widgetList<AnimatedBuilder>(
        find.descendant(
          of: find.byType(IntroScreen),
          matching: find.byType(AnimatedBuilder),
        ),
      )
      .any(
        (widget) =>
            widget.animation is AnimationController &&
            (widget.animation as AnimationController).isAnimating,
      );

  // Otras animaciones del perfil pueden empezar antes de cargar los PNG.
  // Esperar la animación de la intro, no cualquier callback de la aplicación.
  for (var i = 0; i < 250 && !introAnimando(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  expect(introAnimando(), isTrue);
  await tester.pump();
}

class StartupProfileService extends PerfilService {
  final respuesta = Completer<Perfil?>();
  int consultas = 0;
  @override
  Future<Perfil?> obtener(String userId) {
    consultas++;
    return respuesta.future;
  }
}

Widget appConPerfil(StartupProfileService service, GoTrueClient auth) =>
    ChessErciseApp(
      supabaseDisponible: true,
      construirSesion: (onReady) => ChangeNotifierProvider(
        create: (_) => AuthProvider(auth: auth),
        child: ProfileGate(
          userId: 'A',
          service: service,
          onReady: onReady,
          child: const Scaffold(body: Text('Menú preparado')),
        ),
      ),
    );

void main() {
  testWidgets(
    'Profile loads during intro and menu appears without checking screen',
    (tester) async {
      final service = StartupProfileService();
      final auth = GoTrueClient();
      await tester.pumpWidget(appConPerfil(service, auth));
      await cargarIntro(tester);
      expect(service.consultas, 1);
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.text('Comprobando perfil'), findsNothing);
      service.respuesta.complete(
        Perfil(
          id: 'A',
          username: 'Knight',
          fechaNacimiento: DateTime(2000),
          genero: 'otro',
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Menú preparado'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1950));
      await tester.pumpAndSettle();
      expect(find.text('Menú preparado'), findsOneWidget);
      expect(find.byType(IntroScreen), findsNothing);
      expect(find.text('Comprobando perfil'), findsNothing);
      expect(service.consultas, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byType(IntroScreen), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  for (final falla in [false, true]) {
    testWidgets(
      'Slow profile check stays on intro and shows ${falla ? 'error' : 'setup'} directly',
      (tester) async {
        final service = StartupProfileService();
        final auth = GoTrueClient();
        await tester.pumpWidget(appConPerfil(service, auth));
        await cargarIntro(tester);
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        expect(find.text('Preparando tu cuenta…'), findsOneWidget);
        expect(find.text('Comprobando perfil'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        if (falla) {
          service.respuesta.completeError(StateError('offline'));
        } else {
          service.respuesta.complete(null);
        }
        await tester.pumpAndSettle();
        expect(find.byType(IntroScreen), findsNothing);
        expect(find.text('Comprobando perfil'), findsNothing);
        expect(
          find.text(falla ? 'Reintentar' : 'Completa tu perfil'),
          findsOneWidget,
        );
        expect(service.consultas, 1);
        await tester.pumpWidget(const SizedBox.shrink());
        auth.dispose();
      },
    );
  }

  testWidgets(
    'Startup shows intro once, then configuration; rebuild does not replay',
    (tester) async {
      await tester.pumpWidget(const ChessErciseApp(supabaseDisponible: false));
      await cargarIntro(tester);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.text('CHESSERCISE'), findsOneWidget);
      expect(find.text('PLAY. MOVE. WIN.'), findsOneWidget);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(IntroScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        Theme.of(tester.element(find.byType(IntroScreen)))
            .scaffoldBackgroundColor,
      );
      expect(find.textContaining('SUPABASE_URL'), findsNothing);
      await tester.pump(const Duration(milliseconds: 750));
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
