import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'lan_transporte.dart';

LanTransporte crearTransporteLan() => TransporteRealtime();

// El navegador comparte mensajes, sin alojar sockets ni crear tablas.
// El controller existente sigue validando todas las jugadas en el anfitrión.
class TransporteRealtime extends LanTransporte {
  TransporteRealtime({this._client});
  final SupabaseClient? _client;
  final String _id = List.generate(
    16,
    (_) => Random.secure().nextInt(256),
  ).map((n) => n.toRadixString(16).padLeft(2, '0')).join();
  RealtimeChannel? _canal;
  Timer? _latido;
  String? _rival;
  DateTime _ultimoMensaje = DateTime.now();
  bool _host = false;
  bool _cerrado = false;

  @override
  bool get disponible => true;
  @override
  bool get usaCodigo => true;

  Future<void> _entrar(String codigo) async {
    if (_canal != null || _cerrado) throw StateError('Transporte ya usado');
    final listo = Completer<void>();
    final canal = (_client ?? Supabase.instance.client).channel(
      'chessercise-partida-$codigo',
      opts: const RealtimeChannelConfig(ack: true),
    );
    _canal = canal;
    canal.onBroadcast(event: 'partida', callback: _recibir);
    canal.subscribe((status, error) {
      if (_cerrado) return;
      if (status == RealtimeSubscribeStatus.subscribed) {
        if (!listo.isCompleted) listo.complete();
      } else {
        if (!listo.isCompleted) {
          listo.completeError(StateError('No se pudo abrir la sala web.'));
        } else {
          onError?.call(
            'Se perdió la conexión de la sala web. Crea otra sala.',
          );
        }
      }
    });
    try {
      await listo.future.timeout(const Duration(seconds: 12));
      if (_cerrado) throw StateError('Sala cerrada');
      _latido = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_rival == null || _cerrado) return;
        if (DateTime.now().difference(_ultimoMensaje).inSeconds > 35) {
          onCerrar?.call();
          return;
        }
        unawaited(_enviar('latido'));
      });
    } catch (_) {
      await cerrar();
      rethrow;
    }
  }

  void _recibir(Map<String, dynamic> dato) {
    if (_cerrado ||
        dato['id'] is! String ||
        dato['id'] == _id ||
        dato['host'] is! bool ||
        dato['host'] == _host ||
        (dato['para'] != null && dato['para'] != _id)) {
      return;
    }
    final id = dato['id'] as String;
    if (_rival != null && _rival != id) return;
    final mensaje = dato['mensaje'];
    if (_rival == null) {
      if (dato['tipo'] != 'datos' || mensaje is! String) return;
      try {
        final contenido = jsonDecode(mensaje);
        if (contenido is! Map ||
            contenido['tipo'] != (_host ? 'hola' : 'estado')) {
          return;
        }
      } catch (_) {
        return;
      }
      _rival = id;
    }
    _ultimoMensaje = DateTime.now();
    if (dato['tipo'] == 'cerrar') {
      onCerrar?.call();
    } else if (dato['tipo'] == 'datos' &&
        mensaje is String &&
        mensaje.length <= 262144) {
      onMensaje?.call(mensaje);
    }
  }

  Future<void> _enviar(String tipo, [String? mensaje]) async {
    try {
      final respuesta = await _canal!.sendBroadcastMessage(
        event: 'partida',
        payload: {
          'id': _id,
          'host': _host,
          'para': _rival,
          'tipo': tipo,
          'mensaje': ?mensaje,
        },
      );
      if (!_cerrado && respuesta != ChannelResponse.ok) {
        onError?.call(
          'No se pudo enviar la acción. Revisa tu conexión a Internet.',
        );
      }
    } catch (_) {
      if (!_cerrado) onError?.call('Se perdió la conexión de la sala web.');
    }
  }

  @override
  Future<({int puerto, List<String> direcciones})> abrir(
    String codigo, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  }) async {
    _host = true;
    await _entrar(codigo);
    return (puerto: 0, direcciones: <String>[]);
  }

  @override
  Future<void> conectar(String ip, int puerto, String codigo) =>
      _entrar(codigo);

  @override
  void enviar(String mensaje) {
    if (_cerrado || _canal == null) throw StateError('Sin conexión');
    unawaited(_enviar('datos', mensaje));
  }

  @override
  Future<void> cerrar() async {
    if (_cerrado) return;
    _cerrado = true;
    _latido?.cancel();
    if (_canal != null) {
      if (_rival != null) await _enviar('cerrar');
      await (_client ?? Supabase.instance.client).removeChannel(_canal!);
    }
  }
}
