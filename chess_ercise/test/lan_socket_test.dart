import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:chess_ercise/logic/partida_lan_controller.dart';
import 'package:chess_ercise/logic/partida_local_controller.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> esperar(ChangeNotifier origen, bool Function() listo) async {
  if (listo()) return;
  final fin = Completer<void>();
  void cambio() {
    if (listo() && !fin.isCompleted) fin.complete();
  }

  origen.addListener(cambio);
  try {
    await fin.future.timeout(const Duration(seconds: 5));
  } finally {
    origen.removeListener(cambio);
  }
}

Future<void> iguales(
  PartidaLanController host,
  PartidaLanController invitado,
) async {
  await esperar(
    invitado,
    () => invitado.revision == host.revision && !invitado.pendiente,
  );
  expect(invitado.partida.posicion.fen, host.partida.posicion.fen);
  expect(invitado.partida.fase, host.partida.fase);
}

void main() {
  test('El host rechaza revisiones atrasadas y órdenes duplicadas', () async {
    final host = PartidaLanController();
    await host.abrir('Ana', direccion: '127.0.0.1');
    final socket = await io.WebSocket.connect(
      'ws://127.0.0.1:${host.puerto}/partida?sala=${host.codigo}',
    );
    final mensajes = StreamIterator(socket);
    addTearDown(() async {
      await mensajes.cancel();
      await socket.close();
      await host.cerrar();
      host.dispose();
    });
    Future<int> revisionRecibida() async {
      expect(
        await mensajes.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      return (jsonDecode(mensajes.current as String) as Map)['revision'] as int;
    }

    void ordenar(int revision) => socket.add(
      jsonEncode({
        'v': 1,
        'tipo': 'orden',
        'revision': revision,
        'orden': {'tipo': 'mover', 'uci': 'd7d5'},
      }),
    );
    socket.add(jsonEncode({'v': 1, 'tipo': 'hola', 'nombre': 'Luis'}));
    expect(await revisionRecibida(), 0);
    host.jugar(Move.parse('e2e4')!);
    expect(await revisionRecibida(), 1);
    ordenar(0);
    expect(await revisionRecibida(), 1);
    expect(host.partida.posicion.turn, Side.black);
    ordenar(1);
    expect(await revisionRecibida(), 2);
    final fen = host.partida.posicion.fen;
    ordenar(1);
    expect(await revisionRecibida(), 2);
    expect(host.partida.posicion.fen, fen);
  });

  test(
    'WebSocket real: turnos, capturas, retos y confirmaciones coinciden',
    () async {
      final host = PartidaLanController();
      final invitado = PartidaLanController();
      addTearDown(() async {
        await invitado.cerrar();
        await host.cerrar();
        invitado.dispose();
        host.dispose();
      });
      await host.abrir('Ana', direccion: '127.0.0.1');
      await invitado.unirse('Luis', '127.0.0.1:${host.puerto}/${host.codigo}');
      expect(host.conectado, isTrue);
      expect(invitado.lado, Side.black);
      expect(invitado.rival, 'Ana');
      expect(host.rival, 'Luis');
      invitado.jugar(
        Move.parse('e2e4')!,
      ); // El invitado no puede mover blancas.
      await esperar(invitado, () => !invitado.pendiente);
      expect(host.revision, 0);
      host.jugar(Move.parse('e2e4')!);
      await iguales(host, invitado);
      invitado.jugar(Move.parse('d7d5')!);
      await esperar(host, () => host.revision == 2);
      await iguales(host, invitado);
      host.jugar(Move.parse('e4d5')!);
      await iguales(host, invitado);
      expect(host.partida.fase, FaseLocal.eligiendoReto);
      expect(invitado.puedeMover, isFalse);
      host.elegirReto(host.partida.opciones.first.id);
      await iguales(host, invitado);
      invitado.responder(true);
      await esperar(host, () => host.partida.fase == FaseLocal.ejercicio);
      await iguales(host, invitado);
      invitado.listo();
      await esperar(host, () => host.partida.fase == FaseLocal.jugando);
      await iguales(host, invitado);
      invitado.jugar(Move.parse('d8d5')!);
      await esperar(host, () => host.partida.capturador == Side.black);
      await iguales(host, invitado);
      invitado.elegirReto(invitado.partida.opciones.last.id);
      await esperar(host, () => host.partida.fase == FaseLocal.respondiendo);
      await iguales(host, invitado);
      host.responder(false);
      await iguales(host, invitado);
      expect(invitado.partida.fase, FaseLocal.shot);
      host.listo();
      await iguales(host, invitado);
      expect(host.partida.posicion.turn, Side.white);
      expect(host.partida.historial.map((m) => m.san), [
        'e4',
        'd5',
        'exd5',
        'Qxd5',
      ]);
      expect(host.partida.posicionEn(0).fen, Chess.initial.fen);
      expect(
        invitado.partida.posicionEn(2).fen,
        host.partida.posicionEn(2).fen,
      );
      final previa = host.partida.posicion.fen;
      await invitado.cerrar();
      await esperar(host, () => !host.conectado);
      host.jugar(Move.parse('g1f3')!);
      expect(host.partida.posicion.fen, previa);
      expect(host.error, contains('desconectó'));
    },
  );

  test(
    'Código incorrecto y tercer jugador no modifican una sala válida',
    () async {
      final host = PartidaLanController();
      final invitado = PartidaLanController();
      addTearDown(() async {
        await invitado.cerrar();
        await host.cerrar();
        invitado.dispose();
        host.dispose();
      });
      await host.abrir('Ana', direccion: '127.0.0.1');
      final codigoErroneo = host.codigo == '123456' ? '654321' : '123456';
      await expectLater(
        io.WebSocket.connect(
          'ws://127.0.0.1:${host.puerto}/partida?sala=$codigoErroneo',
        ),
        throwsA(isA<io.WebSocketException>()),
      );
      await invitado.unirse('Luis', '127.0.0.1:${host.puerto}/${host.codigo}');
      await expectLater(
        io.WebSocket.connect(
          'ws://127.0.0.1:${host.puerto}/partida?sala=${host.codigo}',
        ),
        throwsA(isA<io.WebSocketException>()),
      );
      expect(host.rival, 'Luis');
      expect(host.revision, 0);
      expect(host.conectado, isTrue);
    },
  );

  test('Accesos mal formados o públicos no inician una conexión', () async {
    for (final acceso in [
      'hola',
      '8.8.8.8:45000/123456',
      '192.168.0.5:45000/no',
      '300.1.1.1:40/123456',
    ]) {
      final invitado = PartidaLanController();
      await expectLater(invitado.unirse('Luis', acceso), throwsFormatException);
      invitado.dispose();
    }
  });
}
