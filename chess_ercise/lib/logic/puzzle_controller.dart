import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../models/puzzle_diario.dart';
import '../models/progreso_puzzle.dart';

// Estado de una sesión de puzzle. La red solo se utiliza para cargar los datos.
class PuzzleController extends ChangeNotifier {
  PuzzleController(this.puzzle, {ProgresoPuzzle? progreso}) {
    posicion = puzzle.posicionInicial;
    ultimaJugada = puzzle.ultimaJugada;
    _posiciones.add(posicion);
    _jugadas.add(ultimaJugada);
    if (progreso != null) {
      errores = progreso.errores;
      _pistas.addAll(progreso.pistas);
      for (final move in puzzle.solucion.take(progreso.indice)) {
        _aplicar(move);
      }
      // Si se cerró la app durante el Timer, completar solo la respuesta pendiente.
      if (!progreso.rendido && !completado && indice.isOdd) {
        _aplicar(puzzle.solucion[indice]);
      }
      if (progreso.rendido) rendirse();
      if (completado) mensaje = '¡Puzzle resuelto!';
    }
  }

  final PuzzleDiario puzzle;
  late Position posicion;
  Move? ultimaJugada;
  int indice = 0;
  int errores = 0;
  bool esperando = false;
  String mensaje = 'Encuentra la mejor jugada.';
  Timer? _respuesta;
  final List<Position> _posiciones = [];
  final List<Move?> _jugadas = [];
  int vista = 0;
  bool rendido = false;
  Square? pista;
  final Set<int> _pistas = {};
  int get pistasUsadas => _pistas.length;
  bool get finalizado => completado || rendido;
  ProgresoPuzzle get estadoGuardado => ProgresoPuzzle(
    indice: indice,
    errores: errores,
    pistas: Set.unmodifiable(_pistas),
    rendido: rendido,
  );

  Position get posicionVisible => _posiciones[vista];
  Move? get jugadaVisible => _jugadas[vista];
  int get totalJugadas => _posiciones.length - 1;
  bool get revisando => vista != totalJugadas;
  bool get puedeRetroceder => vista > 0;
  bool get puedeAvanzar => vista < totalJugadas;
  String get mensajeVisible => rendido
      ? 'Te rendiste. Usa las flechas para ver la solución.'
      : revisando
      ? 'Revisando jugadas. Avanza hasta el final para continuar.'
      : mensaje;

  // SAN se calcula sobre la posición anterior, no sobre el tablero de revisión.
  List<({int numero, Side lado, String san, int vista})> get historial => [
    for (var i = 1; i < _posiciones.length; i++)
      (
        numero: _posiciones[i - 1].fullmoves,
        lado: _posiciones[i - 1].turn,
        san: _posiciones[i - 1].makeSan(_jugadas[i]!).$2,
        vista: i,
      ),
  ];

  void irA(int destino) {
    if (destino < 0 || destino > totalJugadas || destino == vista) return;
    vista = destino;
    pista = null;
    notifyListeners();
  }

  void anterior() => irA(vista - 1);
  void siguiente() => irA(vista + 1);

  void mostrarPista() {
    if (!puedeMover) return;
    final move = puzzle.solucion[indice];
    if (move is NormalMove) {
      pista = move.from;
      _pistas.add(indice);
    }
    notifyListeners();
  }

  // Revelar no aplica movimientos a la partida real ni cuenta como resolverla.
  void rendirse() {
    if (rendido || completado) return;
    _respuesta?.cancel();
    esperando = false;
    rendido = true;
    pista = null;
    var siguientePosicion = posicion;
    for (final move in puzzle.solucion.skip(indice)) {
      siguientePosicion = siguientePosicion.play(move);
      _posiciones.add(siguientePosicion);
      _jugadas.add(move);
    }
    notifyListeners();
  }

  Side get jugador => puzzle.posicionInicial.turn;
  bool get completado => !rendido && indice == puzzle.solucion.length;
  bool get puedeMover => !esperando && !completado && !rendido && !revisando;
  double get progreso => indice / puzzle.solucion.length;

  Move _normalizar(Move move) =>
      move is NormalMove ? posicion.normalizeMove(move) : move;

  void jugar(Move move) {
    if (!puedeMover || !posicion.isLegal(move)) return;
    pista = null;
    if (_normalizar(move) != _normalizar(puzzle.solucion[indice])) {
      errores++;
      mensaje =
          'Esa jugada es legal, pero no es la solución. Inténtalo otra vez.';
      notifyListeners();
      return;
    }
    _aplicar(move);
    if (completado) {
      mensaje = '¡Puzzle resuelto!';
    } else {
      esperando = true;
      mensaje = 'Jugada correcta. Responde el rival…';
      _respuesta = Timer(const Duration(milliseconds: 650), () {
        _aplicar(puzzle.solucion[indice]);
        esperando = false;
        mensaje = 'Tu turno. Encuentra la siguiente jugada.';
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _aplicar(Move move) {
    final siguiendo = !revisando;
    posicion = posicion.play(move);
    ultimaJugada = move;
    indice++;
    _posiciones.add(posicion);
    _jugadas.add(move);
    if (siguiendo) vista = totalJugadas;
  }

  @override
  void dispose() {
    _respuesta?.cancel();
    super.dispose();
  }
}
