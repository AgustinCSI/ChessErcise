import 'reto_local.dart';

class ProgresoPuzzle {
  const ProgresoPuzzle({
    this.indice = 0,
    this.errores = 0,
    this.pistas = const {},
    this.rendido = false,
    this.ejercicioId = 'sentadillas',
    this.rutinaCompletada = false,
  });

  final int indice;
  final int errores;
  // Contar una pista por paso; volver a tocar la bombilla no añade otra.
  final Set<int> pistas;
  final bool rendido;
  final String ejercicioId;
  final bool rutinaCompletada;

  int get repeticiones => errores * 5 + pistas.length * 2;

  ProgresoPuzzle conRutina(String ejercicioId, bool completada) =>
      ProgresoPuzzle(
        indice: indice,
        errores: errores,
        pistas: pistas,
        rendido: rendido,
        ejercicioId: ejercicioId,
        rutinaCompletada: completada,
      );

  Map<String, dynamic> toJson() => {
    'indice': indice,
    'errores': errores,
    'pistas': pistas.toList(),
    'rendido': rendido,
    'ejercicioId': ejercicioId,
    'rutinaCompletada': rutinaCompletada,
  };

  factory ProgresoPuzzle.fromJson(Map<String, dynamic> json, int longitud) {
    final indice = json['indice'] as int;
    final errores = json['errores'] as int;
    final pistas = (json['pistas'] as List).cast<int>().toSet();
    final rendido = json['rendido'] as bool;
    // Los intentos guardados antes de añadir rutinas siguen siendo compatibles.
    final ejercicioId = json['ejercicioId'] as String? ?? 'sentadillas';
    final rutinaCompletada = json['rutinaCompletada'] as bool? ?? false;
    if (indice < 0 ||
        indice > longitud ||
        errores < 0 ||
        pistas.any((p) => p < 0 || p >= longitud || p.isOdd) ||
        (rendido && indice == longitud) ||
        !RetoLocal.catalogo.any((e) => e.id == ejercicioId && !e.porTiempo) ||
        (rutinaCompletada && !rendido && indice != longitud)) {
      throw const FormatException('Progreso de puzzle inválido.');
    }
    return ProgresoPuzzle(
      indice: indice,
      errores: errores,
      pistas: Set.unmodifiable(pistas),
      rendido: rendido,
      ejercicioId: ejercicioId,
      rutinaCompletada: rutinaCompletada,
    );
  }
}
