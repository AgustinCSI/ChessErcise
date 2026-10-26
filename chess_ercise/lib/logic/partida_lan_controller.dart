import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

import '../data/lan_transporte.dart';
import 'partida_local_controller.dart';

// El anfitrión valida; el invitado reproduce comandos aceptados con el mismo motor.
class PartidaLanController extends ChangeNotifier {
  // v2 comparte las dos opciones sorteadas por el anfitrión en cada captura.
  static const versionProtocolo = 2;
  PartidaLanController({LanTransporte? transporte})
    : _transporte = transporte ?? crearTransporteLan() {
    _transporte.onMensaje = _recibir;
    _transporte.onCerrar = () =>
        _fallar('Tu rival se desconectó. Sal y crea o únete a otra sala.');
    _transporte.onError = _fallar;
  }

  final LanTransporte _transporte;
  PartidaLocalController _partida = PartidaLocalController();
  final List<Map<String, dynamic>> _registro = [];
  Completer<void>? _entrada;
  Timer? _espera;
  bool _disposed = false;
  bool _terminal = false;
  bool _iniciado = false;
  bool anfitrion = false;
  bool conectado = false;
  bool pendiente = false;
  String? error;
  String nombre = '';
  String rival = 'Esperando rival';
  String codigo = '';
  int puerto = 0;
  List<String> direcciones = [];

  bool get disponible => _transporte.disponible;
  PartidaLocalController get partida => _partida;
  Side get lado => anfitrion ? Side.white : Side.black;
  int get revision => _registro.length;
  bool get puedeMover =>
      conectado &&
      !pendiente &&
      _partida.puedeMover &&
      _partida.posicion.turn == lado;

  static String validarNombre(String nombre) {
    final limpio = nombre.trim();
    if (limpio.isEmpty || limpio.length > 24) {
      throw const FormatException('Usa un nombre de 1 a 24 caracteres.');
    }
    return limpio;
  }

  Future<void> abrir(
    String usuario, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  }) async {
    if (_iniciado) throw StateError('La sala ya fue iniciada');
    _iniciado = true;
    nombre = validarNombre(usuario);
    anfitrion = true;
    codigo = (100000 + Random.secure().nextInt(900000)).toString();
    final sala = await _transporte.abrir(
      codigo,
      direccion: direccion,
      puerto: puerto,
    );
    if (_disposed) return;
    this.puerto = sala.puerto;
    direcciones = sala.direcciones;
    notifyListeners();
  }

  Future<void> unirse(String usuario, String acceso) async {
    if (_iniciado) throw StateError('La sala ya fue iniciada');
    nombre = validarNombre(usuario);
    final uri = Uri.tryParse('ws://${acceso.trim()}');
    final ip = uri?.host.split('.').map(int.tryParse).toList();
    if (uri == null ||
        ip == null ||
        ip.length != 4 ||
        ip.any((n) => n == null || n < 0 || n > 255) ||
        uri.port < 1 ||
        uri.port > 65535 ||
        !RegExp(r'^/\d{6}$').hasMatch(uri.path) ||
        uri.hasQuery ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw const FormatException(
        'Usa IP:puerto/código, tal como aparece en la sala.',
      );
    }
    // Solo LAN y loopback para pruebas; no se envía el nombre a un host público.
    final privada =
        ip[0] == 10 ||
        ip[0] == 127 ||
        (ip[0] == 192 && ip[1] == 168) ||
        (ip[0] == 172 && ip[1]! >= 16 && ip[1]! <= 31) ||
        (ip[0] == 169 && ip[1] == 254);
    if (!privada) {
      throw const FormatException(
        'Introduce la dirección privada de un dispositivo en tu Wi-Fi.',
      );
    }
    _iniciado = true;
    codigo = uri.path.substring(1);
    _entrada = Completer<void>();
    try {
      await _transporte.conectar(uri.host, uri.port, codigo);
      if (_disposed) return;
      _enviar({'v': versionProtocolo, 'tipo': 'hola', 'nombre': nombre});
      await _entrada!.future.timeout(const Duration(seconds: 12));
    } catch (_) {
      await _transporte.cerrar();
      rethrow;
    }
  }

  void jugar(Move move) => _orden({'tipo': 'mover', 'uci': move.uci});
  void elegirReto(String id) => _orden({'tipo': 'elegir', 'id': id});
  void responder(bool acepta) =>
      _orden({'tipo': 'responder', 'acepta': acepta});
  void listo() => _orden({'tipo': 'listo'});

  bool _aplicar(
    PartidaLocalController juego,
    Side actor,
    Map<String, dynamic> orden, {
    bool reproducir = false,
  }) {
    var cambio = false;
    void marcar() => cambio = true;
    juego.addListener(marcar);
    try {
      switch (orden['tipo']) {
        case 'mover':
          if (actor != juego.posicion.turn || orden['uci'] is! String) break;
          final move = Move.parse(orden['uci'] as String);
          if (move != null) {
            if (reproducir) {
              final opciones = orden['opciones'];
              if (opciones is! List || opciones.any((id) => id is! String)) {
                break;
              }
              juego.jugar(move, opcionesReto: opciones.cast<String>());
            } else {
              juego.jugar(move);
            }
          }
        case 'elegir':
          if (orden['id'] is String) {
            juego.elegirReto(actor, orden['id'] as String);
          }
        case 'responder':
          if (orden['acepta'] is bool) {
            juego.responder(actor, acepta: orden['acepta'] as bool);
          }
        case 'listo':
          juego.listo(actor);
      }
    } finally {
      juego.removeListener(marcar);
    }
    return cambio;
  }

  bool _aceptarOrden(Map<String, dynamic> orden, Side actor) {
    if (!_aplicar(_partida, actor, orden)) return false;
    final tipo = orden['tipo'];
    _registro.add({
      'tipo': tipo,
      'actor': actor == Side.white ? 'white' : 'black',
      if (tipo == 'mover') ...{
        'uci': orden['uci'],
        'opciones': _partida.opciones.map((reto) => reto.id).toList(),
      },
      if (tipo == 'elegir') 'id': orden['id'],
      if (tipo == 'responder') 'acepta': orden['acepta'],
    });
    return true;
  }

  void _orden(Map<String, dynamic> orden) {
    if (_disposed || !conectado || pendiente) {
      return;
    }
    if (_registro.length >= 1000) {
      _fallar('La sala alcanzó su límite de acciones. Crea otra partida.');
      return;
    }
    if (anfitrion) {
      if (_aceptarOrden(orden, Side.white)) {
        _publicar();
        notifyListeners();
      }
    } else {
      pendiente = true;
      _enviar({
        'v': versionProtocolo,
        'tipo': 'orden',
        'revision': revision,
        'orden': orden,
      });
      _espera = Timer(
        const Duration(seconds: 8),
        () => _fallar('El anfitrión no respondió. Sal y vuelve a conectar.'),
      );
      notifyListeners();
    }
  }

  void _publicar() => _enviar({
    'v': versionProtocolo,
    'tipo': 'estado',
    'revision': revision,
    'nombre': nombre,
    'comandos': _registro,
  });

  void _recibir(String raw) {
    if (_disposed || _terminal) return;
    try {
      final mensaje = jsonDecode(raw);
      if (mensaje is! Map<String, dynamic> ||
          mensaje['v'] != versionProtocolo) {
        throw const FormatException();
      }
      if (anfitrion) {
        if (!conectado &&
            mensaje['tipo'] == 'hola' &&
            mensaje['nombre'] is String) {
          rival = validarNombre(mensaje['nombre'] as String);
          conectado = true;
          _publicar();
          notifyListeners();
          return;
        }
        if (!conectado || mensaje['tipo'] != 'orden') return;
        final orden = mensaje['orden'];
        if (mensaje['revision'] == revision &&
            orden is Map<String, dynamic> &&
            _registro.length < 1000 &&
            _aceptarOrden(orden, Side.black)) {
          notifyListeners();
        }
        _publicar(); // También corrige al invitado ante una orden ilegal/atrasada.
      } else {
        if (mensaje['tipo'] != 'estado') return;
        final comandos = mensaje['comandos'];
        final nuevaRevision = mensaje['revision'];
        if (comandos is! List ||
            comandos.length > 1000 ||
            nuevaRevision != comandos.length ||
            nuevaRevision is! int ||
            nuevaRevision < revision ||
            mensaje['nombre'] is! String) {
          throw const FormatException();
        }
        final juego = PartidaLocalController();
        final registro = <Map<String, dynamic>>[];
        try {
          for (final dato in comandos) {
            if (dato is! Map<String, dynamic> ||
                (dato['actor'] != 'white' && dato['actor'] != 'black') ||
                !_aplicar(
                  juego,
                  dato['actor'] == 'white' ? Side.white : Side.black,
                  dato,
                  reproducir: true,
                )) {
              throw const FormatException();
            }
            registro.add(dato);
          }
        } catch (_) {
          juego.dispose();
          rethrow;
        }
        _partida.dispose();
        _partida = juego;
        _registro
          ..clear()
          ..addAll(registro);
        rival = validarNombre(mensaje['nombre'] as String);
        conectado = true;
        pendiente = false;
        _espera?.cancel();
        if (_entrada != null && !_entrada!.isCompleted) _entrada!.complete();
        notifyListeners();
      }
    } catch (_) {
      _fallar('Los datos de la sala no son compatibles. Crea otra sala.');
    }
  }

  void _enviar(Map<String, dynamic> mensaje) {
    try {
      _transporte.enviar(jsonEncode(mensaje));
    } catch (_) {
      _fallar('No se pudo enviar la jugada. Revisa la conexión.');
    }
  }

  void _fallar(String mensaje) {
    if (_disposed || _terminal) return;
    _terminal = true;
    unawaited(_transporte.cerrar());
    error = mensaje;
    conectado = false;
    pendiente = false;
    _espera?.cancel();
    if (_entrada != null && !_entrada!.isCompleted) {
      _entrada!.completeError(StateError(mensaje));
    }
    notifyListeners();
  }

  Future<void> cerrar() async {
    _terminal = true;
    conectado = false;
    _espera?.cancel();
    await _transporte.cerrar();
  }

  @override
  void dispose() {
    _disposed = true;
    _espera?.cancel();
    unawaited(_transporte.cerrar());
    _partida.dispose();
    super.dispose();
  }
}
