import 'dart:async';
import 'dart:io';

import 'lan_transporte.dart';

LanTransporte crearTransporteLan() => _TransporteSocket();

class _TransporteSocket extends LanTransporte {
  HttpServer? _servidor;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _lectura;
  bool _cerrado = false;
  bool _ocupado = false;

  @override
  bool get disponible => true;

  @override
  Future<({int puerto, List<String> direcciones})> abrir(
    String codigo, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  }) async {
    if (_servidor != null || _socket != null || _cerrado) {
      throw StateError('Transporte ya usado');
    }
    final servidor = await HttpServer.bind(direccion, puerto);
    if (_cerrado) {
      await servidor.close(force: true);
      throw StateError('Sala cerrada');
    }
    _servidor = servidor;
    servidor.listen(
      (request) async {
        try {
          if (_cerrado ||
              _ocupado ||
              request.uri.path != '/partida' ||
              request.uri.queryParameters['sala'] != codigo ||
              !WebSocketTransformer.isUpgradeRequest(request)) {
            request.response.statusCode = HttpStatus.forbidden;
            await request.response.close();
            return;
          }
          _ocupado = true; // Reservar antes del await: no entran dos invitados a la vez.
          final socket = await WebSocketTransformer.upgrade(
            request,
            maxPayloadLength: 262144,
          );
          if (_cerrado) {
            await socket.close();
            return;
          }
          _escuchar(socket);
        } catch (_) {
          if (!_cerrado) {
            onError?.call('No se pudo aceptar al invitado. Crea otra sala.');
          }
        }
      },
      onError: (Object _) {
        if (!_cerrado) onError?.call('Se cerró el servidor local.');
      },
    );
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: direccion == '127.0.0.1',
    );
    final direcciones = interfaces
        .expand((red) => red.addresses)
        .map((ip) => ip.address)
        .toSet()
        .toList();
    return (puerto: servidor.port, direcciones: direcciones);
  }

  @override
  Future<void> conectar(String ip, int puerto, String codigo) async {
    if (_cerrado || _socket != null) throw StateError('Transporte ya usado');
    final conexion = WebSocket.connect(
      Uri(
        scheme: 'ws',
        host: ip,
        port: puerto,
        path: '/partida',
        queryParameters: {'sala': codigo},
      ).toString(),
    );
    // Si el usuario sale o vence el plazo, cerrar también una conexión tardía.
    unawaited(
      conexion.then<void>((socket) async {
        if (_cerrado) await socket.close();
      }, onError: (Object _) {}),
    );
    final socket = await conexion.timeout(const Duration(seconds: 12));
    if (_cerrado) {
      await socket.close();
      return;
    }
    _escuchar(socket);
  }

  void _escuchar(WebSocket socket) {
    _socket = socket;
    socket.pingInterval = const Duration(seconds: 5);
    _lectura = socket.listen(
      (dato) {
        if (!_cerrado && dato is String && dato.length <= 262144) {
          onMensaje?.call(dato);
        }
      },
      onDone: () {
        if (!_cerrado) onCerrar?.call();
      },
      onError: (Object _) {
        if (!_cerrado) onError?.call('Se perdió la conexión Wi-Fi.');
      },
    );
  }

  @override
  void enviar(String mensaje) {
    if (_cerrado || _socket == null || _socket!.readyState != WebSocket.open) {
      throw StateError('Sin conexión');
    }
    _socket!.add(mensaje);
  }

  @override
  Future<void> cerrar() async {
    if (_cerrado) return;
    _cerrado = true;
    await _lectura?.cancel();
    await _socket?.close(WebSocketStatus.goingAway);
    await _servidor?.close(force: true);
  }
}
