import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/perfil_service.dart';
import '../../models/perfil.dart';

class PerfilProvider extends ChangeNotifier {
  PerfilProvider({required this.userId, PerfilService? service})
    : _service = service ?? PerfilService();

  final String userId;
  final PerfilService _service;
  Perfil? perfil;
  Uint8List? fotoBytes;
  String? errorFoto;
  String? _fotoPath;

  Future<void> _cargarFoto(String? path, int revision) async {
    if (path == _fotoPath && fotoBytes != null) return;
    fotoBytes = null;
    _fotoPath = path;
    errorFoto = null;
    if (path == null) return;
    try {
      final bytes = await _service
          .descargarFoto(path)
          .timeout(const Duration(seconds: 15));
      if (_disposed || revision != _revision) return;
      fotoBytes = bytes;
    } catch (_) {
      if (_disposed || revision != _revision) return;
      errorFoto =
          'No se pudo cargar la foto. Se reintentará al volver a abrir la app.';
    }
    if (!_disposed && revision == _revision) _avisar();
  }

  bool cargando = true;
  bool guardando = false;
  String? errorCarga;
  bool _disposed = false;
  int _revision = 0;

  Future<void> cargar() async {
    if (guardando) return;
    final revision = ++_revision;
    cargando = true;
    errorCarga = null;
    _avisar();
    try {
      final resultado = await _service.obtener(userId);
      if (_disposed || revision != _revision) return;
      if (resultado != null && resultado.id != userId) {
        throw StateError('Perfil ajeno');
      }
      perfil = resultado;
      _cargarFoto(resultado?.avatarPath, revision);
    } on PostgrestException catch (e) {
      if (revision != _revision) return;
      errorCarga = e.code == 'PGRST205' || e.code == '42P01'
          ? 'Falta configurar la tabla de perfiles. Consulta supabase/README.md.'
          : 'No se pudo comprobar tu perfil. Revisa tu conexión y reintenta.';
    } catch (_) {
      if (revision != _revision) return;
      errorCarga =
          'No se pudo comprobar tu perfil. Revisa tu conexión y reintenta.';
    } finally {
      if (revision == _revision) {
        cargando = false;
        _avisar();
      }
    }
  }

  Future<String?> guardar(
    String username,
    DateTime fecha,
    String genero, {
    Uint8List? foto,
  }) async {
    if (guardando || cargando) {
      return 'Espera a que termine la solicitud actual.';
    }
    final nuevo = Perfil(
      id: userId,
      username: username.trim(),
      fechaNacimiento: fecha,
      genero: genero,
      avatarPath: perfil?.avatarPath,
    );
    if (!nuevo.completo) return 'Revisa los datos del formulario.';
    ++_revision;
    guardando = true;
    _avisar();
    try {
      final resultado = foto == null
          ? await _service.guardar(nuevo)
          : await _service.guardarConFoto(nuevo, foto);
      if (resultado.id != userId || !resultado.completo) {
        return 'No se pudo confirmar que el perfil quedó completo.';
      }
      if (!_disposed) {
        perfil = resultado;
        if (foto != null) {
          fotoBytes = foto;
          _fotoPath = resultado.avatarPath;
          errorFoto = null;
        } else {
          _cargarFoto(resultado.avatarPath, _revision);
        }
      }
      return null;
    } on FormatException catch (e) {
      return e.message;
    } on StorageException catch (_) {
      return 'No se pudo subir la foto. Revisa tu conexión e inténtalo otra vez.';
    } on PostgrestException catch (e) {
      if (e.code == '23505') return 'Ese nombre de usuario ya está ocupado.';
      return 'No se pudo guardar tu perfil. Inténtalo otra vez.';
    } catch (_) {
      return 'No se pudo guardar tu perfil. Revisa tu conexión.';
    } finally {
      guardando = false;
      _avisar();
    }
  }

  void _avisar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    super.dispose();
  }
}
