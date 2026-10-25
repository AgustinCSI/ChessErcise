import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/lichess_puzzles_service.dart';
import '../../models/progreso_puzzle.dart';
import '../../models/puzzle_diario.dart';

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
  final Map<String, ProgresoPuzzle> _progresos = {};
  Future<void> _escrituras = Future.value();
  bool _disposed = false;
  String? errorGuardado;
  int _pendientes = 0;
  bool get guardando => _pendientes > 0;
  String get _base => 'chessercise.v1.$userId';

  // Política de caché de la app: revalidar al cambiar la fecha UTC.
  Future<PuzzleDiario> obtenerDiario() {
    final dia = _ahora().toUtc().toIso8601String().substring(0, 10);
    if (_future != null && dia == _dia) return _future!;
    _dia = dia;
    final future = _cargar(dia);
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

  Future<PuzzleDiario> _cargar(String dia) async {
    final prefs = await SharedPreferences.getInstance();
    PuzzleDiario? puzzle;
    final cache = prefs.getString('$_base.daily');
    if (cache != null) {
      try {
        final json = jsonDecode(cache) as Map<String, dynamic>;
        if (json['dia'] == dia) {
          puzzle = PuzzleDiario.fromJson(
            json['puzzle'] as Map<String, dynamic>,
          );
        }
      } catch (_) {
        // Caché de contenido inválida: consultar nuevamente la fuente.
      }
    }
    puzzle ??= await _service.obtenerDiario();
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
        jsonEncode({'dia': dia, 'puzzle': contenido.toJson()}),
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
    final raw = jsonEncode(progreso.toJson());
    return _escribir(() async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('$_base.progress.${puzzle.id}', raw)) {
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
