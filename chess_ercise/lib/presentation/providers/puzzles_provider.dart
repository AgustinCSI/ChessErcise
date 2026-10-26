import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/lichess_puzzles_service.dart';
import '../../models/progreso_puzzle.dart';
import '../../models/puzzle_diario.dart';
import '../../models/reto_local.dart';

// Un provider por sesión: comparte precarga, caché y progreso entre pantallas.
class PuzzlesProvider extends ChangeNotifier {
  PuzzlesProvider({
    required this.userId,
    LichessPuzzlesService? service,
    DateTime Function()? ahora,
  }) : _service = service ?? LichessPuzzlesService(),
       _ahora = ahora ?? DateTime.now;

  final String userId;
  final LichessPuzzlesService _service;
  final DateTime Function() _ahora;
  Future<PuzzleDiario>? _future;
  String? _dia;
  DateTime? _vence;
  static const vigenciaCache = Duration(minutes: 15);
  final Map<String, ProgresoPuzzle> _progresos = {};
  Future<void> _escrituras = Future.value();
  bool _disposed = false;
  String? errorGuardado;
  int _pendientes = 0;
  bool get guardando => _pendientes > 0;
  String get _base => 'chessercise.v1.$userId';

  // La fecha UTC sola no garantiza que Lichess ya haya publicado el siguiente.
  Future<PuzzleDiario> obtenerDiario({bool actualizar = false}) {
    final ahora = _ahora().toUtc();
    final dia = ahora.toIso8601String().substring(0, 10);
    if (!actualizar &&
        _future != null &&
        dia == _dia &&
        (_vence == null || ahora.isBefore(_vence!))) {
      return _future!;
    }
    _dia = dia;
    _vence = null;
    final future = _cargar(dia, actualizar: actualizar);
    _future = future;
    // La precarga puede fallar sin bloquear el menú. La pantalla permite reintentar.
    future.then<void>(
      (_) {},
      onError: (Object e, StackTrace st) {
        if (identical(_future, future)) _future = null;
      },
    );
    return future;
  }

  void precargar() {
    obtenerDiario(); // obtenerDiario ya registra un manejador de errores.
  }

  Future<PuzzleDiario> _cargar(String dia, {required bool actualizar}) async {
    final prefs = await SharedPreferences.getInstance();
    PuzzleDiario? puzzle;
    PuzzleDiario? anterior;
    DateTime? consultadoEn;
    final cache = prefs.getString('$_base.daily');
    if (cache != null) {
      try {
        final json = jsonDecode(cache) as Map<String, dynamic>;
        if (json['dia'] == dia) {
          anterior = PuzzleDiario.fromJson(
            json['puzzle'] as Map<String, dynamic>,
          );
          consultadoEn = DateTime.tryParse(
            json['consultadoEn'] as String? ?? '',
          );
          final ahora = _ahora().toUtc();
          if (!actualizar &&
              consultadoEn != null &&
              !consultadoEn.isAfter(ahora) &&
              ahora.isBefore(consultadoEn.add(vigenciaCache))) {
            puzzle = anterior;
          }
        }
      } catch (_) {
        // Caché de contenido inválida: consultar nuevamente la fuente.
      }
    }
    if (puzzle == null) {
      final recibido = await _service.obtenerDiario();
      // Mantener la valoración del intento al revalidar el mismo puzzle.
      puzzle = recibido.id == anterior?.id ? anterior! : recibido;
      consultadoEn = _ahora().toUtc();
    }
    if (_dia == dia) _vence = consultadoEn!.add(vigenciaCache);
    final contenido = puzzle;
    final raw = prefs.getString('$_base.progress.${contenido.id}');
    // Un progreso ilegible no se sustituye por un intento nuevo silenciosamente.
    _progresos.putIfAbsent(
      puzzle.id,
      () => raw == null
          ? const ProgresoPuzzle()
          : ProgresoPuzzle.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
              contenido.solucion.length,
            ),
    );
    await _escribir(() async {
      if (!await prefs.setString(
        '$_base.daily',
        jsonEncode({
          'dia': dia,
          'consultadoEn': consultadoEn!.toIso8601String(),
          'puzzle': contenido.toJson(),
        }),
      )) {
        throw StateError('No se pudo guardar la caché');
      }
    });
    return puzzle;
  }

  ProgresoPuzzle progresoPara(PuzzleDiario puzzle) =>
      _progresos[puzzle.id] ?? const ProgresoPuzzle();

  Future<void> guardar(PuzzleDiario puzzle, ProgresoPuzzle progreso) {
    final anterior = _progresos[puzzle.id];
    // Un resultado final queda sellado, aunque se vuelva a abrir otra pantalla.
    if (anterior != null &&
        (anterior.rendido || anterior.indice == puzzle.solucion.length)) {
      return _escrituras;
    }
    _progresos[puzzle.id] = progreso;
    return _guardarProgreso(puzzle.id, progreso);
  }

  // Solo actualiza la rutina: el resultado del tablero permanece sellado.
  Future<void> guardarRutina(
    PuzzleDiario puzzle,
    String ejercicioId, {
    bool completada = false,
  }) {
    final progreso = _progresos[puzzle.id];
    if (progreso == null ||
        (!progreso.rendido && progreso.indice != puzzle.solucion.length) ||
        progreso.rutinaCompletada ||
        progreso.repeticiones == 0 ||
        !RetoLocal.catalogo.any((e) => e.id == ejercicioId && !e.porTiempo)) {
      return _escrituras;
    }
    final actualizado = progreso.conRutina(ejercicioId, completada);
    _progresos[puzzle.id] = actualizado;
    return _guardarProgreso(puzzle.id, actualizado);
  }

  Future<void> _guardarProgreso(String puzzleId, ProgresoPuzzle progreso) {
    final raw = jsonEncode(progreso.toJson());
    return _escribir(() async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('$_base.progress.$puzzleId', raw)) {
        throw StateError('No se pudo guardar el progreso');
      }
    });
  }

  Future<void> reintentarGuardado() {
    final valores = Map<String, ProgresoPuzzle>.from(_progresos);
    return _escribir(() async {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in valores.entries) {
        if (!await prefs.setString(
          '$_base.progress.${entry.key}',
          jsonEncode(entry.value.toJson()),
        )) {
          throw StateError('No se pudo guardar el progreso');
        }
      }
    });
  }

  Future<void> _escribir(Future<void> Function() operacion) {
    _pendientes++;
    _avisar();
    _escrituras = _escrituras.then((_) async {
      try {
        await operacion();
        errorGuardado = null;
      } catch (_) {
        errorGuardado = 'No se pudo guardar en este dispositivo. Reintenta antes de cerrar la app.';
      } finally {
        _pendientes--;
        _avisar();
      }
    });
    return _escrituras;
  }

  void _avisar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _service.dispose();
    super.dispose();
  }
}
