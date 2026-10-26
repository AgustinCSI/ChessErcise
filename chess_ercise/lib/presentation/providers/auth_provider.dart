import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';

// null significa éxito; un String significa error, como en el ejemplo de clase.
class AuthProvider extends ChangeNotifier {
  AuthProvider({GoTrueClient? auth})
    : _auth = auth ?? Supabase.instance.client.auth;

  final GoTrueClient _auth;
  bool cargando = false;
  bool requiereConfirmacion = false;
  bool _disposed = false;

  Future<String?> ingresar(String correo, String clave) => _ejecutar(() async {
    requiereConfirmacion = false;
    await _auth.signInWithPassword(email: correo.trim(), password: clave);
  });

  Future<String?> registrar(String correo, String clave) => _ejecutar(() async {
    requiereConfirmacion = false;
    final res = await _auth.signUp(
      email: correo.trim(),
      password: clave,
      emailRedirectTo: AppConfig.authRedirectUrl,
    );
    requiereConfirmacion = res.session == null;
  });

  Future<String?> salir() => _ejecutar(() async {
    await _auth.signOut();
  });

  Future<String?> _ejecutar(Future<void> Function() accion) async {
    if (cargando) return 'Espera a que termine la solicitud actual.';
    cargando = true;
    notifyListeners();
    try {
      await accion();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Algo salió mal. Revisa tu conexión e inténtalo otra vez.';
    } finally {
      cargando = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
