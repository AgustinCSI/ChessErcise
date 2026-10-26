import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../models/reto_local.dart';

enum FaseLocal {
  jugando,
  eligiendoReto,
  respondiendo,
  ejercicio,
  shot,
  finalizada,
}

// Una sola autoridad en memoria: no crea salas, sockets ni cuentas invitadas.
class PartidaLocalController extends ChangeNotifier {
  PartidaLocalController({Position? inicial, Random? azar})
    : _posicion = inicial ?? Chess.initial,
      _azar = azar ?? Random() {
    _repeticiones[_clave(_posicion)] = 1;
    if (_posicion.isGameOver) _fase = FaseLocal.finalizada;
  }

  Position _posicion;
  FaseLocal _fase = FaseLocal.jugando;
  Move? _ultimaJugada;
  Side? _capturador;
  Role? _piezaCapturada;
  RetoLocal? _reto;
  final Random _azar;
  List<RetoLocal> _opciones = const [];
  final Map<String, int> _repeticiones = {};
  bool _tablasPorRegla = false;
  final List<Position> _posiciones = [];
  final List<Move> _jugadas = [];

  int get totalJugadas => _jugadas.length;
  Position posicionEn(int vista) => vista == 0
      ? (_posiciones.isEmpty ? _posicion : _posiciones.first)
      : _posiciones[vista];
  Move? jugadaEn(int vista) => vista == 0 ? null : _jugadas[vista - 1];
  List<({int numero, Side lado, String san, int vista})> get historial => [
    for (var i = 0; i < _jugadas.length; i++)
      (
        numero: _posiciones[i].fullmoves,
        lado: _posiciones[i].turn,
        san: _posiciones[i].makeSan(_jugadas[i]).$2,
        vista: i + 1,
      ),
  ];

  Position get posicion => _posicion;
  FaseLocal get fase => _fase;
  Move? get ultimaJugada => _ultimaJugada;
  Side? get capturador => _capturador;
  Side? get retado => _capturador?.opposite;
  Role? get piezaCapturada => _piezaCapturada;
  RetoLocal? get reto => _reto;
  bool get puedeMover => _fase == FaseLocal.jugando;
  List<RetoLocal> get opciones => _opciones;

  String get resultado {
    if (_fase != FaseLocal.finalizada) return '';
    if (_tablasPorRegla) return 'Tablas por repetición o regla de 50 jugadas';
    final ganador = _posicion.outcome?.winner;
    if (ganador == null) return 'Tablas';
    return ganador == Side.white ? 'Ganan las blancas' : 'Ganan las negras';
  }

  // La FEN omite contadores para reconocer una posición repetida.
  String _clave(Position posicion) => posicion.fen.split(' ').take(4).join(' ');

  void jugar(Move move, {List<String>? opcionesReto}) {
    if (!puedeMover || !_posicion.isLegal(move)) return;
    Piece? capturada;
    if (move is NormalMove) {
      final destino = _posicion.board.pieceAt(move.to);
      if (destino?.color == _posicion.turn.opposite) capturada = destino;
      // En passant: el destino está vacío, pero se retira el peón rival.
      final origen = _posicion.board.pieceAt(move.from);
      if (origen?.role == Role.pawn &&
          move.to == _posicion.epSquare &&
          destino == null) {
        capturada = Piece(color: _posicion.turn.opposite, role: Role.pawn);
      }
    }
    List<RetoLocal> opciones = const [];
    if (capturada != null) {
      if (opcionesReto == null) {
        opciones = RetoLocal.seleccionarParaPieza(capturada.role, _azar);
      } else {
        final disponibles = {
          for (final reto in RetoLocal.paraPieza(capturada.role)) reto.id: reto,
        };
        if (opcionesReto.length != 2 ||
            opcionesReto.toSet().length != 2 ||
            opcionesReto.any((id) => !disponibles.containsKey(id))) {
          return;
        }
        opciones = List.unmodifiable(
          opcionesReto.map((id) => disponibles[id]!),
        );
      }
    } else if (opcionesReto != null && opcionesReto.isNotEmpty) {
      return;
    }
    final quienJugo = _posicion.turn;
    if (_posiciones.isEmpty) _posiciones.add(_posicion);
    _posicion = _posicion.play(move);
    _posiciones.add(_posicion);
    _jugadas.add(move);
    _ultimaJugada = move;
    final clave = _clave(_posicion);
    _repeticiones[clave] = (_repeticiones[clave] ?? 0) + 1;
    // Primera versión local: cierre automático al alcanzar estos límites.
    _tablasPorRegla = _repeticiones[clave]! >= 3 || _posicion.halfmoves >= 100;
    if (capturada != null) {
      _capturador = quienJugo;
      _piezaCapturada = capturada.role;
      _opciones = opciones;
      _fase = FaseLocal.eligiendoReto;
    } else {
      _continuar();
    }
    notifyListeners();
  }

  void elegirReto(Side actor, String id) {
    if (_fase != FaseLocal.eligiendoReto || actor != _capturador) return;
    final encontrados = opciones.where((opcion) => opcion.id == id);
    if (encontrados.isEmpty) return;
    _reto = encontrados.first;
    _fase = FaseLocal.respondiendo;
    notifyListeners();
  }

  void responder(Side actor, {required bool acepta}) {
    if (_fase != FaseLocal.respondiendo || actor != retado) return;
    _fase = acepta ? FaseLocal.ejercicio : FaseLocal.shot;
    notifyListeners();
  }

  void listo(Side actor) {
    if (actor != retado ||
        (_fase != FaseLocal.ejercicio && _fase != FaseLocal.shot)) {
      return;
    }
    _reto = null;
    _opciones = const [];
    _capturador = null;
    _piezaCapturada = null;
    _continuar();
    notifyListeners();
  }

  void _continuar() {
    _fase = _posicion.isGameOver || _tablasPorRegla
        ? FaseLocal.finalizada
        : FaseLocal.jugando;
  }

  void reiniciar() {
    _posiciones.clear();
    _jugadas.clear();
    _posicion = Chess.initial;
    _ultimaJugada = null;
    _capturador = null;
    _piezaCapturada = null;
    _reto = null;
    _opciones = const [];
    _tablasPorRegla = false;
    _repeticiones
      ..clear()
      ..[_clave(_posicion)] = 1;
    _fase = FaseLocal.jugando;
    notifyListeners();
  }
}
