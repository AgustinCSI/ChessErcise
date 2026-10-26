import 'lan_transporte_stub.dart'
    if (dart.library.io) 'lan_transporte_io.dart'
    if (dart.library.js_interop) 'lan_transporte_realtime.dart'
    as plataforma;

// Android/nativo utiliza sockets locales; la web comparte mensajes por Realtime.
abstract class LanTransporte {
  bool get disponible;
  bool get usaCodigo => false;
  void Function(String)? onMensaje;
  void Function()? onCerrar;
  void Function(String)? onError;
  Future<({int puerto, List<String> direcciones})> abrir(
    String codigo, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  });
  Future<void> conectar(String ip, int puerto, String codigo);
  void enviar(String mensaje);
  Future<void> cerrar();
}

LanTransporte crearTransporteLan() => plataforma.crearTransporteLan();
