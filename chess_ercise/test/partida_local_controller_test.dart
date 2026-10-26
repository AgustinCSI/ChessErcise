import 'package:chess_ercise/logic/partida_local_controller.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

void mover(PartidaLocalController partida, List<String> jugadas) {
  for (final uci in jugadas) {
    final jugada = Move.parse(uci)!;
    expect(partida.posicion.isLegal(jugada), isTrue, reason: uci);
    partida.jugar(jugada);
  }
}

void main() {
  test('Captura pausa; solo el capturador elige y el retado acepta/Listo', () {
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    final inicio = partida.posicion.fen;
    partida.jugar(Move.parse('e7e5')!);
    expect(partida.posicion.fen, inicio);
    mover(partida, ['e2e4', 'd7d5', 'e4d5']);
    expect(partida.fase, FaseLocal.eligiendoReto);
    expect(partida.piezaCapturada, Role.pawn);
    expect(partida.capturador, Side.white);
    expect(partida.retado, Side.black);
    final captura = partida.posicion.fen;
    partida.jugar(Move.parse('g8f6')!);
    expect(partida.posicion.fen, captura);
    partida.elegirReto(Side.black, partida.opciones.first.id);
    partida.elegirReto(Side.white, 'inexistente');
    expect(partida.fase, FaseLocal.eligiendoReto);
    partida.elegirReto(Side.white, partida.opciones.first.id);
    partida.responder(Side.white, acepta: true);
    partida.listo(Side.black);
    expect(partida.fase, FaseLocal.respondiendo);
    partida.responder(Side.black, acepta: true);
    expect(partida.fase, FaseLocal.ejercicio);
    partida.listo(Side.white);
    expect(partida.puedeMover, isFalse);
    partida.listo(Side.black);
    expect(partida.puedeMover, isTrue);
    expect(partida.posicion.turn, Side.black);
    expect(partida.reto, isNull);
    mover(partida, ['g8f6']);
    expect(partida.posicion.turn, Side.white);
  });

  test('Captura de negras y rechazo: shot espera confirmación de blancas', () {
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    mover(partida, ['e2e4', 'd7d5', 'g1f3', 'd5e4']);
    expect(partida.capturador, Side.black);
    partida.elegirReto(Side.black, partida.opciones.last.id);
    partida.responder(Side.white, acepta: false);
    expect(partida.fase, FaseLocal.shot);
    partida.listo(Side.black);
    expect(partida.puedeMover, isFalse);
    partida.listo(Side.white);
    expect(partida.posicion.turn, Side.white);
    expect(partida.puedeMover, isTrue);
  });

  test('En passant reconoce el peón capturado en una casilla vacía', () {
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    mover(partida, ['e2e4', 'a7a6', 'e4e5', 'd7d5', 'e5d6']);
    expect(partida.piezaCapturada, Role.pawn);
    expect(partida.posicion.board.pieceAt(Square.d5), isNull);
    expect(partida.fase, FaseLocal.eligiendoReto);
  });

  test('Enroque no es captura; promoción conserva la pieza elegida', () {
    final enroque = PartidaLocalController(
      inicial: Chess.fromSetup(
        Setup.parseFen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1'),
      ),
    );
    final promocion = PartidaLocalController(
      inicial: Chess.fromSetup(Setup.parseFen('7k/P7/8/8/8/8/8/7K w - - 0 1')),
    );
    addTearDown(enroque.dispose);
    addTearDown(promocion.dispose);
    mover(enroque, ['e1h1']);
    expect(enroque.posicion.board.pieceAt(Square.g1)?.role, Role.king);
    expect(enroque.fase, FaseLocal.jugando);
    expect(enroque.piezaCapturada, isNull);
    mover(promocion, ['a7a8n']);
    expect(promocion.posicion.board.pieceAt(Square.a8)?.role, Role.knight);
    expect(promocion.fase, FaseLocal.finalizada);
  });

  test('Captura con mate resuelve el reto antes de mostrar el resultado', () {
    final partida = PartidaLocalController(
      inicial: Chess.fromSetup(
        Setup.parseFen('7k/5Q1p/6K1/8/8/8/8/8 w - - 0 1'),
      ),
    );
    addTearDown(partida.dispose);
    mover(partida, ['f7h7']);
    expect(partida.posicion.isCheckmate, isTrue);
    expect(partida.fase, FaseLocal.eligiendoReto);
    partida.elegirReto(Side.white, partida.opciones.first.id);
    partida.responder(Side.black, acepta: true);
    partida.listo(Side.black);
    expect(partida.resultado, 'Ganan las blancas');
    expect(partida.puedeMover, isFalse);
    partida.reiniciar();
    expect(partida.posicion.fen, Chess.initial.fen);
    expect(partida.ultimaJugada, isNull);
    expect(partida.fase, FaseLocal.jugando);
  });

  test('Repetición cierra la partida local y bloquea movimientos', () {
    final partida = PartidaLocalController();
    addTearDown(partida.dispose);
    mover(partida, [
      'g1f3',
      'g8f6',
      'f3g1',
      'f6g8',
      'g1f3',
      'g8f6',
      'f3g1',
      'f6g8',
    ]);
    expect(partida.fase, FaseLocal.finalizada);
    expect(partida.resultado, contains('Tablas'));
  });
}
