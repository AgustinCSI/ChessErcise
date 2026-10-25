import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../models/puzzle_diario.dart';

// Estado de una sesión de puzzle. La red solo se utiliza para cargar los datos.
class PuzzleController extends ChangeNotifier {
  PuzzleController(this.puzzle) {
    posicion = puzzle.posicionInicial;
    ultimaJugada = puzzle.ultimaJugada;
  }

  final PuzzleDiario puzzle;
  late Position posicion;
  Move? ultimaJugada;
  int indice = 0;
  int errores = 0;
  bool esperando = false;
  String mensaje = 'Encuentra la mejor jugada.';
  Timer? _respuesta;

  Side get jugador => puzzle.posicionInicial.turn;
  bool get completado => indice == puzzle.solucion.length;
  bool get puedeMover => !esperando && !completado;
  double get progreso => indice / puzzle.solucion.length;

  Move _normalizar(Move move) =>
      move is NormalMove ? posicion.normalizeMove(move) : move;

  void jugar(Move move) {
    if (!puedeMover || !posicion.isLegal(move)) return;
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
    posicion = posicion.play(move);
    ultimaJugada = move;
    indice++;
  }

  void reiniciar() {
    _respuesta?.cancel();
    posicion = puzzle.posicionInicial;
    ultimaJugada = puzzle.ultimaJugada;
    indice = 0;
    errores = 0;
    esperando = false;
    mensaje = 'Encuentra la mejor jugada.';
    notifyListeners();
  }

  @override
  void dispose() {
    _respuesta?.cancel();
    super.dispose();
  }
}
