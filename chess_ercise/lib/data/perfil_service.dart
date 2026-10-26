import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/perfil.dart';

class PerfilService {
  PerfilService([this._client]);
  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? Supabase.instance.client;

  Future<Perfil?> obtener(String userId) async {
    final json = await client
        .from('profiles')
        .select('id,username,birth_date,gender,avatar_path')
        .eq('id', userId)
        .maybeSingle();
    return json == null ? null : Perfil.fromJson(json);
  }

  Future<Perfil> guardar(Perfil perfil) async {
    final json = await client
        .from('profiles')
        .upsert(perfil.toJson(), onConflict: 'id')
        .select('id,username,birth_date,gender,avatar_path')
        .single();
    return Perfil.fromJson(json);
  }

  static const maxFotoBytes = 2 * 1024 * 1024;

  static ({String extension, String mime}) tipoFoto(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxFotoBytes) {
      throw const FormatException('La foto debe pesar como máximo 2 MB.');
    }
    if (bytes.length >= 8 &&
        bytes.take(8).join(',') == '137,80,78,71,13,10,26,10') {
      return (extension: 'png', mime: 'image/png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      return (extension: 'jpg', mime: 'image/jpeg');
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
        String.fromCharCodes(bytes.skip(8).take(4)) == 'WEBP') {
      return (extension: 'webp', mime: 'image/webp');
    }
    throw const FormatException('Elige una imagen JPG, PNG o WebP.');
  }

  Future<Uint8List> descargarFoto(String path) =>
      client.storage.from('avatars').download(path);

  Future<String> subirFoto(String userId, Uint8List bytes) async {
    final tipo = tipoFoto(bytes);
    final path =
        '$userId/${DateTime.now().microsecondsSinceEpoch}.${tipo.extension}';
    await client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: tipo.mime, upsert: false),
        );
    return path;
  }

  Future<void> borrarFoto(String path) async {
    await client.storage.from('avatars').remove([path]);
  }

  Future<Perfil> guardarConFoto(Perfil perfil, Uint8List bytes) async {
    tipoFoto(bytes);
    final path = await subirFoto(perfil.id, bytes);
    late Perfil guardado;
    try {
      guardado = await guardar(
        Perfil(
          id: perfil.id,
          username: perfil.username,
          fechaNacimiento: perfil.fechaNacimiento,
          genero: perfil.genero,
          avatarPath: path,
        ),
      );
    } catch (_) {
      // No cambiar la imagen anterior si falla el guardado de los datos.
      try {
        await borrarFoto(path);
      } catch (_) {
        /* Limpieza best effort. */
      }
      rethrow;
    }
    if (perfil.avatarPath != null && perfil.avatarPath != path) {
      try {
        await borrarFoto(perfil.avatarPath!);
      } catch (_) {
        /* No invalida el nuevo perfil. */
      }
    }
    return guardado;
  }
}
