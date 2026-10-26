class Perfil {
  const Perfil({
    required this.id,
    required this.username,
    required this.fechaNacimiento,
    required this.genero,
    this.avatarPath,
  });

  final String id;
  final String username;
  final DateTime? fechaNacimiento;
  final String genero;
  final String? avatarPath;

  static const generos = {
    'mujer': 'Mujer',
    'hombre': 'Hombre',
    'no_binario': 'No binario',
    'otro': 'Otro',
    'prefiero_no_decir': 'Prefiero no decirlo',
  };

  static String? validarUsername(String? value) =>
      RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Usa 3–20 letras, números o guion bajo.';

  static bool fechaValida(DateTime? fecha, {DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    return fecha != null &&
        !fecha.isBefore(DateTime(1900)) &&
        !fecha.isAfter(DateTime(ahora.year, ahora.month, ahora.day));
  }

  bool get completo =>
      validarUsername(username) == null &&
      fechaValida(fechaNacimiento) &&
      generos.containsKey(genero);

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
    id: json['id'] as String,
    username: json['username'] as String? ?? '',
    fechaNacimiento: DateTime.tryParse(json['birth_date'] as String? ?? ''),
    genero: json['gender'] as String? ?? '',
    avatarPath: json['avatar_path'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username.trim(),
    'birth_date': fechaNacimiento?.toIso8601String().substring(0, 10),
    'gender': genero,
    'avatar_path': avatarPath,
  };
}
