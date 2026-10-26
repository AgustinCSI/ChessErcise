import 'dart:math';

import 'package:chess_ercise/logic/partida_local_controller.dart';
import 'package:chess_ercise/models/reto_local.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('El catálogo contiene exactamente los nueve ejercicios pedidos', () {
    expect(RetoLocal.catalogo.map((ejercicio) => ejercicio.titulo).toSet(), {
      'Flexiones de brazos',
      'Flexiones con rodillas apoyadas',
      'Abdominales tradicionales',
      'Plancha frontal',
      'Plancha lateral',
      'Sentadillas',
      'Zancadas',
      'Rodillas al pecho',
      'Trote en el lugar',
    });
    expect(RetoLocal.catalogo.length, 9);
    expect(
      RetoLocal.catalogo.map((ejercicio) => ejercicio.id).toSet().length,
      9,
    );
  });

  test(
    'Cada sorteo ofrece dos distintos del catálogo y todos pueden salir',
    () {
      final vistos = <String>{};
      for (var semilla = 0; semilla < 100; semilla++) {
        for (final pieza in [
          Role.pawn,
          Role.knight,
          Role.bishop,
          Role.rook,
          Role.queen,
        ]) {
          final opciones = RetoLocal.seleccionarParaPieza(
            pieza,
            Random(semilla),
          );
          expect(opciones.length, 2);
          expect(opciones.map((reto) => reto.id).toSet().length, 2);
          final permitidos = RetoLocal.paraPieza(pieza)
              .map((reto) => reto.id)
              .toSet();
          expect(
            opciones.every((reto) => permitidos.contains(reto.id)),
            isTrue,
          );
          if (pieza == Role.pawn) {
            vistos.addAll(opciones.map((reto) => reto.titulo));
          }
        }
      }
      expect(vistos.length, 9);
      expect(RetoLocal.seleccionarParaPieza(Role.king, Random(0)), isEmpty);
    },
  );

  test('Repeticiones y segundos conservan la escala por pieza', () {
    for (final pieza in [
      Role.pawn,
      Role.knight,
      Role.bishop,
      Role.rook,
      Role.queen,
    ]) {
      final valor = RetoLocal.valorDe(pieza);
      final opciones = RetoLocal.paraPieza(pieza);
      for (final id in ['plancha-frontal', 'plancha-lateral', 'trote']) {
        expect(
          opciones.singleWhere((reto) => reto.id == '$id-$valor').indicacion,
          '${valor * 5} segundos',
        );
      }
      expect(
        opciones
            .singleWhere((reto) => reto.id == 'sentadillas-$valor')
            .indicacion,
        '$valor ${valor == 1 ? 'repetición' : 'repeticiones'}',
      );
    }
  });

  test(
    'Una captura mantiene sus dos opciones y solo permite elegir una de ellas',
    () {
      final partida = PartidaLocalController(azar: Random(7));
      addTearDown(partida.dispose);
      for (final uci in ['e2e4', 'd7d5', 'e4d5']) {
        partida.jugar(Move.parse(uci)!);
      }
      final ids = partida.opciones.map((reto) => reto.id).toList();
      for (var lectura = 0; lectura < 20; lectura++) {
        expect(partida.opciones.map((reto) => reto.id), ids);
      }
      final ausente = RetoLocal.paraPieza(Role.pawn)
          .firstWhere((reto) => !ids.contains(reto.id));
      partida.elegirReto(Side.white, ausente.id);
      expect(partida.fase, FaseLocal.eligiendoReto);
      partida.elegirReto(Side.white, ids.first);
      expect(partida.reto!.id, ids.first);
      partida.responder(Side.black, acepta: true);
      partida.listo(Side.black);
      expect(partida.opciones, isEmpty);
      partida.reiniciar();
      expect(partida.opciones, isEmpty);
    },
  );

  test(
    'Replay exige dos IDs válidos distintos antes de aplicar una captura',
    () {
      final partida = PartidaLocalController();
      addTearDown(partida.dispose);
      for (final uci in ['e2e4', 'd7d5']) {
        partida.jugar(Move.parse(uci)!);
      }
      final antes = partida.posicion.fen;
      for (final invalido in <List<String>>[
        [],
        ['sentadillas-1'],
        ['sentadillas-1', 'sentadillas-1'],
        ['sentadillas-1', 'no-existe'],
        ['sentadillas-1', 'plancha-frontal-9'],
        ['sentadillas-1', 'flexiones-1', 'trote-1'],
      ]) {
        partida.jugar(Move.parse('e4d5')!, opcionesReto: invalido);
        expect(partida.posicion.fen, antes);
        expect(partida.totalJugadas, 2);
        expect(partida.fase, FaseLocal.jugando);
      }
      const ids = ['plancha-frontal-1', 'flexiones-rodillas-1'];
      partida.jugar(Move.parse('e4d5')!, opcionesReto: ids);
      expect(partida.opciones.map((reto) => reto.id), ids);
      expect(partida.fase, FaseLocal.eligiendoReto);
    },
  );
}
