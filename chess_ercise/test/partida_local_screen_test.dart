import 'package:chess_ercise/logic/partida_local_controller.dart';
import 'package:chess_ercise/presentation/screens/local/local_setup_screen.dart';
import 'package:chess_ercise/presentation/screens/local/partida_local_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:chess_ercise/presentation/widgets/panel_jugador_local.dart';
import 'package:chess_ercise/presentation/widgets/tablero_interactivo.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void mover(PartidaLocalController partida, List<String> jugadas) {
  for (final uci in jugadas) {
    final jugada = Move.parse(uci)!;
    expect(partida.posicion.isLegal(jugada), isTrue, reason: uci);
    partida.jugar(jugada);
  }
}

void main() {
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
      await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Salir de la partida').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seguir jugando'));
    await tester.pumpAndSettle();
    expect(find.byType(PartidaLocalScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Salir de la partida').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    expect(find.text('Escribe un nombre'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Ana');
    await tester.ensureVisible(find.text('Comenzar partida'));
    await tester.tap(find.text('Comenzar partida'));
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    var tablero = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(tablero.orientation, Side.white);
    expect(
      tablero.settings.pieceOrientationBehavior,
      PieceOrientationBehavior.opponentUpsideDown,
    );
    expect(tablero.controller.game.playerSide, PlayerSide.none);
    expect(find.text('Aceptar reto'), findsNothing);
    final elegir = find.text('Sentadillas · 1 repetición');
    await tester.ensureVisible(elegir);
    await tester.tap(elegir);
    await tester.pumpAndSettle();
    final aceptar = find.text('Aceptar reto');
    await tester.ensureVisible(aceptar);
    await tester.tap(aceptar);
    await tester.pumpAndSettle();
    expect(partida.fase, FaseLocal.ejercicio);
    await tester.ensureVisible(find.text('Listo'));
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    tablero = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(tablero.controller.game.playerSide, PlayerSide.black);
    expect(tablero.orientation, Side.white);
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
    await tester.pumpAndSettle();
    expect(find.text('Tomar shot'), findsOneWidget);
    expect(partida.puedeMover, isFalse);
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(partida.puedeMover, isTrue);
  });

  for (final size in [
    const Size(360, 640),
    const Size(800, 1280),
    const Size(844, 390),
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
      await tester.pumpAndSettle();
      expect(find.byType(TableroInteractivo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
