import 'lan_transporte.dart';

LanTransporte crearTransporteLan() => _NoDisponible();

class _NoDisponible extends LanTransporte {
  @override
  bool get disponible => false;
  Never _noDisponible() =>
      throw UnsupportedError('Local Wi-Fi requiere la aplicación Android.');
  @override
  Future<({int puerto, List<String> direcciones})> abrir(
    String codigo, {
    String direccion = '0.0.0.0',
    int puerto = 0,
  }) async => _noDisponible();
  @override
  Future<void> conectar(String ip, int puerto, String codigo) async =>
      _noDisponible();
  @override
  void enviar(String mensaje) => _noDisponible();
  @override
  Future<void> cerrar() async {}
}
