import 'dart:async';
import 'dart:convert';

import 'package:chess_ercise/data/lan_transporte.dart';
import 'package:chess_ercise/logic/partida_lan_controller.dart';
import 'package:chess_ercise/presentation/screens/local/local_modes_screen.dart';
import 'package:chess_ercise/presentation/screens/local/local_setup_screen.dart';
import 'package:chess_ercise/presentation/screens/local/wifi_lobby_screen.dart';
import 'package:chess_ercise/presentation/screens/local/partida_wifi_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:chess_ercise/presentation/widgets/tablero_interactivo.dart';
import 'package:chess_ercise/presentation/widgets/tira_jugadas.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Transporte de prueba para aislar la UI; los sockets reales se prueban aparte.
class TransporteGuion extends LanTransporte {
  TransporteGuion({this.reto = false});
  final bool reto;
  final comandos = <Map<String, dynamic>>[
    {'tipo': 'mover', 'uci': 'e2e4', 'actor': 'white', 'opciones': <String>[]},
    {'tipo': 'mover', 'uci': 'e7e5', 'actor': 'black', 'opciones': <String>[]},
    {'tipo': 'mover', 'uci': 'g1f3', 'actor': 'white', 'opciones': <String>[]},
  ];
  @override
  bool get disponible => true;
  @override
  Future<({int puerto, List<String> direcciones})> abrir(
    String codigo, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  }) async => (puerto: 45000, direcciones: ['192.168.1.5']);
  @override
  Future<void> conectar(String ip, int puerto, String codigo) async {}
  @override
  void enviar(String raw) {
    final mensaje = jsonDecode(raw) as Map<String, dynamic>;
    if (mensaje['tipo'] == 'hola' && reto) {
      comandos
        ..clear()
        ..addAll([
          {
            'tipo': 'mover',
            'uci': 'e2e4',
            'actor': 'white',
            'opciones': <String>[],
          },
          {
            'tipo': 'mover',
            'uci': 'd7d5',
            'actor': 'black',
            'opciones': <String>[],
          },
          {
            'tipo': 'mover',
            'uci': 'e4d5',
            'actor': 'white',
            'opciones': ['sentadillas-1', 'flexiones-1'],
          },
          {'tipo': 'elegir', 'id': 'sentadillas-1', 'actor': 'white'},
        ]);
    } else if (mensaje['tipo'] == 'orden') {
      comandos.add({
        ...mensaje['orden'] as Map<String, dynamic>,
        'actor': 'black',
      });
    }
    scheduleMicrotask(
      () => onMensaje?.call(
        jsonEncode({
          'v': PartidaLanController.versionProtocolo,
          'tipo': 'estado',
          'nombre': 'Ana',
          'revision': comandos.length,
          'comandos': comandos,
        }),
      ),
    );
  }

  @override
  Future<void> cerrar() async {}
}

void main() {
  testWidgets('Selector ofrece dos cuadros y conserva frente a frente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const LocalModesScreen()),
    );
    expect(find.text('Frente a frente'), findsOneWidget);
    expect(find.text('Local Wi-Fi'), findsOneWidget);
    await tester.tap(find.text('Frente a frente'));
    await tester.pumpAndSettle();
    expect(find.byType(LocalSetupScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Local Wi-Fi'));
    await tester.pumpAndSettle();
    expect(find.byType(WifiLobbyScreen), findsOneWidget);
    expect(find.text('Crear sala'), findsOneWidget);
    expect(find.text('Unirme a una sala'), findsOneWidget);
  });

  testWidgets(
    'Historial compartido revisa sin alterar partida ni permitir mover',
    (tester) async {
      final lan = PartidaLanController(transporte: TransporteGuion());
      addTearDown(lan.dispose);
      await lan.unirse('Luis', '192.168.1.5:45000/123456');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: PartidaWifiScreen(lan: lan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TiraJugadas), findsOneWidget);
      final actual = lan.partida.posicion.fen;
      expect(lan.puedeMover, isTrue);
      await tester.tap(find.byTooltip('1. e4'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TableroInteractivo>(find.byType(TableroInteractivo))
            .posicion
            .fen,
        lan.partida.posicionEn(1).fen,
      );
      expect(
        tester
            .widget<Chessboard>(find.byType(Chessboard))
            .controller
            .game
            .playerSide,
        PlayerSide.none,
      );
      expect(lan.partida.posicion.fen, actual);
      await tester.tap(find.text('Volver a la partida'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Chessboard>(find.byType(Chessboard))
            .controller
            .game
            .playerSide,
        PlayerSide.black,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Reto Wi-Fi reutiliza el panel y cierra el diálogo al confirmar',
    (tester) async {
      final lan = PartidaLanController(transporte: TransporteGuion(reto: true));
      addTearDown(lan.dispose);
      await lan.unirse('Luis', '192.168.1.5:45000/123456');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: PartidaWifiScreen(lan: lan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('Aceptar reto'));
      await tester.pumpAndSettle();
      expect(find.text('Listo'), findsOneWidget);
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(lan.puedeMover, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(360, 640),
    const Size(800, 1280),
    const Size(844, 390),
    const Size(1024, 800),
  ]) {
    testWidgets('Wi-Fi cabe en $size con texto ampliado', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lan = PartidaLanController(transporte: TransporteGuion());
      addTearDown(lan.dispose);
      await lan.unirse('Luis', '192.168.1.5:45000/123456');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: PartidaWifiScreen(lan: lan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TableroInteractivo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
