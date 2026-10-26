import 'dart:math';

import 'package:dartchess/dartchess.dart';

// Catálogo inicial sin red. No representa ejercicios guardados en Supabase.
class RetoLocal {
  const RetoLocal(this.id, this.titulo, this.indicacion, this.valor);

  final String id;
  final String titulo;
  final String indicacion;
  final int valor;

  // El sufijo del ID indica el valor de la pieza; la ilustración es la misma.
  String get imagen {
    final ejercicio = id.replaceFirst(RegExp(r'-\d+$'), '');
    final archivo = switch (ejercicio) {
      'flexiones' => 'FlexionesBrazos',
      'flexiones-rodillas' => 'FlexionesRodillasApoyadas',
      'abdominales' => 'AbdominalesTradicionales',
      'plancha-frontal' => 'PlanchaFrontal',
      'plancha-lateral' => 'PlanchaLateral',
      'sentadillas' => 'Sentadilla',
      'zancadas' => 'Zancada',
      'rodillas-pecho' => 'rodillasPecho',
      'trote' => 'TroteEnLugar',
      _ => 'FlexionesBrazos',
    };
    return 'assets/IconosDeportes/$archivo.png';
  }

  static const catalogo = <({String id, String titulo, bool porTiempo})>[
    (id: 'flexiones', titulo: 'Flexiones de brazos', porTiempo: false),
    (
      id: 'flexiones-rodillas',
      titulo: 'Flexiones con rodillas apoyadas',
      porTiempo: false,
    ),
    (id: 'abdominales', titulo: 'Abdominales tradicionales', porTiempo: false),
    (id: 'plancha-frontal', titulo: 'Plancha frontal', porTiempo: true),
    (id: 'plancha-lateral', titulo: 'Plancha lateral', porTiempo: true),
    (id: 'sentadillas', titulo: 'Sentadillas', porTiempo: false),
    (id: 'zancadas', titulo: 'Zancadas', porTiempo: false),
    (id: 'rodillas-pecho', titulo: 'Rodillas al pecho', porTiempo: false),
    (id: 'trote', titulo: 'Trote en el lugar', porTiempo: true),
  ];

  static int valorDe(Role pieza) => switch (pieza) {
    Role.pawn => 1,
    Role.knight || Role.bishop => 3,
    Role.rook => 5,
    Role.queen => 9,
    Role.king => 0,
  };

  static String nombreDe(Role pieza) => switch (pieza) {
    Role.pawn => 'peón',
    Role.knight => 'caballo',
    Role.bishop => 'alfil',
    Role.rook => 'torre',
    Role.queen => 'dama',
    Role.king => 'rey',
  };

  static List<RetoLocal> paraPieza(Role pieza) {
    final valor = valorDe(pieza);
    if (valor == 0) return const [];
    final cantidad = '$valor ${valor == 1 ? 'repetición' : 'repeticiones'}';
    return [
      for (final ejercicio in catalogo)
        RetoLocal(
          '${ejercicio.id}-$valor',
          ejercicio.titulo,
          ejercicio.porTiempo ? '${valor * 5} segundos' : cantidad,
          valor,
        ),
    ];
  }

  static List<RetoLocal> seleccionarParaPieza(Role pieza, Random azar) {
    final posibles = paraPieza(pieza);
    if (posibles.isEmpty) return const [];
    posibles.shuffle(azar);
    return List.unmodifiable(posibles.take(2));
  }
}
