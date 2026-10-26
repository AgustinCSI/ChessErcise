import 'dart:io' as io;

import 'package:chess_ercise/logic/partida_local_controller.dart';
import 'package:chess_ercise/models/perfil.dart';
import 'package:chess_ercise/presentation/providers/perfil_provider.dart';
import 'package:chess_ercise/presentation/screens/local/local_setup_screen.dart';
import 'package:chess_ercise/presentation/screens/local/partida_local_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:chess_ercise/presentation/widgets/panel_jugador_local.dart';
import 'package:chess_ercise/presentation/widgets/tablero_interactivo.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void mover(PartidaLocalController partida, List<String> jugadas) {
  for (final uci in jugadas) {
    final jugada = Move.parse(uci)!;
    expect(partida.posicion.isLegal(jugada), isTrue, reason: uci);
    partida.jugar(jugada);
  }
}

// Una espera activa anima continuamente: avanzamos un intervalo acotado.
Future<void> avanzarInterfaz(WidgetTester tester) async {
  await tester.pump();
  if (find.byKey(const ValueKey('punto-espera-0')).evaluate().isNotEmpty) {
    await tester.pump(const Duration(milliseconds: 1100));
  } else {
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final nombres in [
    ('Cuenta', 'Invitado', 1),
    (' cuenta ', 'CUENTA', 2),
    ('Invitado 1', 'Invitado 2', 0),
  ]) {
    testWidgets('Foto de la sesion en ${nombres.$3} paneles coincidentes', (
      tester,
    ) async {
      final perfil = PerfilProvider(userId: 'sesion')
        ..perfil = Perfil(
          id: 'sesion',
          username: 'Cuenta',
          fechaNacimiento: DateTime(2000),
          genero: 'prefiero_no_decir',
        )
        ..fotoBytes = io.File('assets/intro_screen/PiezaRey.png')
            .readAsBytesSync();
      addTearDown(perfil.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: perfil,
          child: MaterialApp(
            theme: AppTheme.claro,
            home: PartidaLocalScreen(
              nombreBlancas: nombres.$1,
              nombreNegras: nombres.$2,
            ),
          ),
        ),
      );
      await avanzarInterfaz(tester);
      final avatares = tester.widgetList<CircleAvatar>(
        find.byType(CircleAvatar),
      );
      expect(
        avatares
            .where((avatar) => avatar.backgroundImage is MemoryImage)
            .length,
        nombres.$3,
      );
      expect(
        avatares.where((avatar) => avatar.backgroundImage == null).length,
        2 - nombres.$3,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Toques de ambos jugadores mueven sobre el tablero fijo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaLocalScreen(partida: partida),
      ),
    );
    Future<void> tocar(int columna, int fila) async {
      final rect = tester.getRect(find.byType(Chessboard));
      await tester.tapAt(
        rect.topLeft +
            Offset(
              (columna + .5) * rect.width / 8,
              (fila + .5) * rect.height / 8,
            ),
      );
      await avanzarInterfaz(tester);
    }

    await tocar(4, 6); // e2
    await tocar(4, 4); // e4
    expect(partida.posicion.turn, Side.black);
    await tocar(3, 1); // d7, desde la zona superior
    await tocar(3, 3); // d5
    expect(partida.posicion.turn, Side.white);
    await tocar(4, 4);
    await tocar(3, 3);
    expect(partida.fase, FaseLocal.eligiendoReto);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Salir permite cancelar y luego volver a preparación', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const LocalSetupScreen()),
    );
    await tester.ensureVisible(find.text('Comenzar partida'));
    await tester.tap(find.text('Comenzar partida'));
    await avanzarInterfaz(tester);
    await tester.tap(find.byTooltip('Salir de la partida').last);
    await avanzarInterfaz(tester);
    await tester.tap(find.text('Seguir jugando'));
    await avanzarInterfaz(tester);
    expect(find.byType(PartidaLocalScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Salir de la partida').last);
    await avanzarInterfaz(tester);
    await tester.tap(find.text('Salir'));
    await avanzarInterfaz(tester);
    expect(find.byType(PartidaLocalScreen), findsNothing);
    expect(find.text('Comenzar partida'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Preparación valida nombres y abre la partida real', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const LocalSetupScreen()),
    );
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.ensureVisible(find.text('Comenzar partida'));
    await tester.tap(find.text('Comenzar partida'));
    await avanzarInterfaz(tester);
    expect(find.text('Escribe un nombre'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Ana');
    await tester.ensureVisible(find.text('Comenzar partida'));
    await tester.tap(find.text('Comenzar partida'));
    await avanzarInterfaz(tester);
    expect(find.byType(PartidaLocalScreen), findsOneWidget);
    expect(find.text('Ana · Blancas'), findsOneWidget);
  });

  testWidgets('Panel superior invertido; tablero fijo y sin acciones rivales', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaLocalScreen(partida: partida),
      ),
    );
    final panelNegro = find.byWidgetPredicate(
      (widget) => widget is PanelJugadorLocal && widget.lado == Side.black,
    );
    expect(
      tester
          .widget<RotatedBox>(
            find
                .ancestor(of: panelNegro, matching: find.byType(RotatedBox))
                .first,
          )
          .quarterTurns,
      2,
    );
    mover(partida, ['e2e4', 'd7d5', 'e4d5']);
    await avanzarInterfaz(tester);
    var tablero = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(tablero.orientation, Side.white);
    expect(
      tablero.settings.pieceOrientationBehavior,
      PieceOrientationBehavior.opponentUpsideDown,
    );
    expect(tablero.controller.game.playerSide, PlayerSide.none);
    expect(find.byKey(const ValueKey('velo-reto-local')), findsOneWidget);
    final punto = find.byKey(const ValueKey('punto-espera-0'));
    final posicionAntes = tester
        .widget<Transform>(punto)
        .transform
        .getTranslation()
        .y;
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.widget<Transform>(punto).transform.getTranslation().y,
      isNot(closeTo(posicionAntes, .01)),
    );
    final ilustraciones = tester
        .widgetList<Image>(find.byType(Image))
        .where(
          (imagen) =>
              imagen.image is AssetImage &&
              (imagen.image as AssetImage).assetName.startsWith(
                'assets/IconosDeportes/',
              ),
        );
    expect(ilustraciones.length, 2);
    expect(
      ilustraciones
          .map((imagen) => (imagen.image as AssetImage).assetName)
          .toSet(),
      partida.opciones.map((reto) => reto.imagen).toSet(),
    );
    expect(find.text('Aceptar reto'), findsNothing);
    final opcion = partida.opciones.first;
    final elegir = find.text('${opcion.titulo} · ${opcion.indicacion}');
    await tester.ensureVisible(elegir);
    await tester.tap(elegir);
    await avanzarInterfaz(tester);
    final aceptar = find.text('Aceptar reto');
    await tester.ensureVisible(aceptar);
    await tester.tap(aceptar);
    await avanzarInterfaz(tester);
    expect(partida.fase, FaseLocal.ejercicio);
    await tester.ensureVisible(find.text('Listo'));
    await tester.tap(find.text('Listo'));
    await avanzarInterfaz(tester);
    tablero = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(tablero.controller.game.playerSide, PlayerSide.black);
    expect(tablero.orientation, Side.white);
    expect(find.byKey(const ValueKey('velo-reto-local')), findsNothing);
    expect(find.byKey(const ValueKey('punto-espera-0')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rechazo muestra animación y el tablero permanece bloqueado', (
    tester,
  ) async {
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    mover(partida, ['e2e4', 'd7d5', 'e4d5']);
    partida.elegirReto(Side.white, partida.opciones.first.id);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaLocalScreen(partida: partida),
      ),
    );
    await tester.ensureVisible(find.text('Rechazar'));
    await tester.tap(find.text('Rechazar'));
    await avanzarInterfaz(tester);
    expect(find.text('Tomar shot'), findsOneWidget);
    expect(partida.puedeMover, isFalse);
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await avanzarInterfaz(tester);
    expect(partida.puedeMover, isTrue);
  });

  for (final size in [
    const Size(360, 640),
    const Size(800, 1280),
    const Size(844, 390),
    const Size(1024, 800),
  ]) {
    testWidgets('Sin desbordamiento en $size con texto ampliado', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final partida = PartidaLocalController();
      addTearDown(partida.dispose);
      mover(partida, ['e2e4', 'd7d5', 'e4d5']);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: PartidaLocalScreen(partida: partida),
        ),
      );
      await avanzarInterfaz(tester);
      expect(find.byType(TableroInteractivo), findsOneWidget);
      final centro = tester.getCenter(find.byType(TableroInteractivo));
      expect(centro.dx, closeTo(size.width / 2, 1));
      expect(centro.dy, closeTo(size.height / 2, 1));
      expect(tester.takeException(), isNull);
    });
  }
}
