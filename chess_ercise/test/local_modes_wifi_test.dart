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
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Transporte de prueba para aislar la UI; los sockets reales se prueban aparte.
class TransporteGuion extends LanTransporte {
  TransporteGuion({this.reto = false, this.elegido = true});
  final bool reto;
  final bool elegido;
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
          if (elegido)
            {'tipo': 'elegir', 'id': 'sentadillas-1', 'actor': 'white'},
        ]);
    } else if (mensaje['tipo'] == 'orden') {
      comandos.add({
        ...mensaje['orden'] as Map<String, dynamic>,
        'actor': 'black',
        if (mensaje['orden']['tipo'] == 'mover') 'opciones': <String>[],
      });
    }
    publicar();
  }

  void publicar() {
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

Future<void> avanzarWifi(WidgetTester tester) async {
  await tester.pump();
  if (find.byKey(const ValueKey('punto-espera-0')).evaluate().isNotEmpty) {
    await tester.pump(const Duration(milliseconds: 1100));
  } else {
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('Espera de reto permite revisar sin actuar por el rival', (
    tester,
  ) async {
    final transporte = TransporteGuion(reto: true, elegido: false);
    final lan = PartidaLanController(transporte: transporte);
    addTearDown(lan.dispose);
    await lan.unirse('Luis', '192.168.1.5:45000/123456');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaWifiScreen(lan: lan),
      ),
    );
    await avanzarWifi(tester);
    expect(find.text('Aceptar reto'), findsNothing);
    expect(find.text('Sentadillas · 1 repetición'), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    await tester.tap(find.byTooltip('1. e4'));
    await avanzarWifi(tester);
    final historica = lan.partida.posicionEn(1).fen;
    transporte.comandos.add({
      'tipo': 'elegir',
      'id': 'sentadillas-1',
      'actor': 'white',
    });
    transporte.publicar();
    await avanzarWifi(tester);
    expect(find.text('Aceptar reto'), findsOneWidget);
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .posicion
          .fen,
      historica,
    );
    await tester.ensureVisible(find.text('Rechazar'));
    await tester.tap(find.text('Rechazar'));
    await avanzarWifi(tester);
    expect(find.text('Tomar shot'), findsOneWidget);
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await avanzarWifi(tester);
    expect(find.text('Volver a la partida'), findsOneWidget);
    expect(lan.puedeMover, isTrue);
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .puedeMover,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Revision conserva posicion al recibir la jugada del rival', (
    tester,
  ) async {
    final transporte = TransporteGuion();
    final lan = PartidaLanController(transporte: transporte);
    addTearDown(lan.dispose);
    await lan.unirse('Luis', '192.168.1.5:45000/123456');
    lan.jugar(Move.parse('b8c6')!);
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaWifiScreen(lan: lan),
      ),
    );
    await avanzarWifi(tester);
    expect(lan.puedeMover, isFalse);
    await tester.tap(find.byTooltip('1. e4'));
    await avanzarWifi(tester);
    final historica = lan.partida.posicionEn(1).fen;
    transporte.comandos.add({
      'tipo': 'mover',
      'uci': 'f1b5',
      'actor': 'white',
      'opciones': <String>[],
    });
    transporte.publicar();
    await avanzarWifi(tester);
    expect(lan.puedeMover, isTrue);
    final tablero = tester.widget<TableroInteractivo>(
      find.byType(TableroInteractivo),
    );
    expect(tablero.posicion.fen, historica);
    expect(tablero.puedeMover, isFalse);
    expect(find.text('Jugada 1 de 5'), findsOneWidget);
    await tester.tap(find.byTooltip('Jugada siguiente'));
    await avanzarWifi(tester);
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .posicion
          .fen,
      lan.partida.posicionEn(2).fen,
    );
    await tester.tap(find.text('Volver a la partida'));
    await avanzarWifi(tester);
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .posicion
          .fen,
      lan.partida.posicion.fen,
    );
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .puedeMover,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Selector ofrece dos cuadros y conserva frente a frente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const LocalModesScreen()),
    );
    expect(find.text('Frente a frente'), findsOneWidget);
    expect(find.text('Local Wi-Fi'), findsOneWidget);
    await tester.tap(find.text('Frente a frente'));
    await avanzarWifi(tester);
    expect(find.byType(LocalSetupScreen), findsOneWidget);
    await tester.pageBack();
    await avanzarWifi(tester);
    await tester.tap(find.text('Local Wi-Fi'));
    await avanzarWifi(tester);
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
      await avanzarWifi(tester);
      expect(find.byType(TiraJugadas), findsOneWidget);
      final actual = lan.partida.posicion.fen;
      expect(lan.puedeMover, isTrue);
      await tester.tap(find.byTooltip('1. e4'));
      await avanzarWifi(tester);
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
      await avanzarWifi(tester);
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

  testWidgets('Reto Wi-Fi integrado permite revisar y confirmar sin dialogos', (
    tester,
  ) async {
    final lan = PartidaLanController(transporte: TransporteGuion(reto: true));
    addTearDown(lan.dispose);
    await lan.unirse('Luis', '192.168.1.5:45000/123456');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PartidaWifiScreen(lan: lan),
      ),
    );
    await avanzarWifi(tester);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byKey(const ValueKey('velo-reto-wifi')), findsOneWidget);
    await tester.tap(find.byTooltip('1. e4'));
    await avanzarWifi(tester);
    expect(find.byKey(const ValueKey('velo-reto-wifi')), findsNothing);
    expect(find.text('Volver a la partida'), findsOneWidget);
    await tester.ensureVisible(find.text('Aceptar reto'));
    await tester.tap(find.text('Aceptar reto'));
    await avanzarWifi(tester);
    expect(find.text('Listo'), findsOneWidget);
    await tester.ensureVisible(find.text('Listo'));
    await tester.tap(find.text('Listo'));
    await avanzarWifi(tester);
    expect(find.byType(Dialog), findsNothing);
    expect(lan.puedeMover, isTrue);
    // El reto termina, pero revisar no permite mover desde una posicion pasada.
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .puedeMover,
      isFalse,
    );
    await tester.tap(find.text('Volver a la partida'));
    await avanzarWifi(tester);
    expect(
      tester
          .widget<TableroInteractivo>(find.byType(TableroInteractivo))
          .puedeMover,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

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
      await avanzarWifi(tester);
      expect(find.byType(TableroInteractivo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
