class ProgresoPuzzle {
  const ProgresoPuzzle({
    this.indice = 0,
    this.errores = 0,
    this.pistas = const {},
    this.rendido = false,
  });

  final int indice;
  final int errores;
  // Contar una pista por paso; volver a tocar la bombilla no añade otra.
  final Set<int> pistas;
  final bool rendido;

  Map<String, dynamic> toJson() => {
    'indice': indice,
    'errores': errores,
    'pistas': pistas.toList(),
    'rendido': rendido,
  };

  factory ProgresoPuzzle.fromJson(Map<String, dynamic> json, int longitud) {
    final indice = json['indice'] as int;
    final errores = json['errores'] as int;
    final pistas = (json['pistas'] as List).cast<int>().toSet();
    final rendido = json['rendido'] as bool;
    if (indice < 0 ||
        indice > longitud ||
        errores < 0 ||
        pistas.any((p) => p < 0 || p >= longitud || p.isOdd) ||
        (rendido && indice == longitud)) {
      throw const FormatException('Progreso de puzzle inválido.');
    }
    return ProgresoPuzzle(
      indice: indice,
      errores: errores,
      pistas: Set.unmodifiable(pistas),
      rendido: rendido,
    );
  }
}
