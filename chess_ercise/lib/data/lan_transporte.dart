import 'lan_transporte_stub.dart'
    if (dart.library.io) 'lan_transporte_io.dart'
    as plataforma;

// El navegador puede mostrar el lobby; alojar sockets requiere Android/nativo.
abstract class LanTransporte {
  bool get disponible;
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
