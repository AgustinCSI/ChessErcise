import 'package:dartchess/dartchess.dart';

// Catálogo inicial sin red. No representa ejercicios guardados en Supabase.
class RetoLocal {
  const RetoLocal(this.id, this.titulo, this.indicacion, this.valor);

  final String id;
  final String titulo;
  final String indicacion;
  final int valor;

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
    final cantidad = '$valor ${valor == 1 ? 'repetición' : 'repeticiones'}';
    return [
      RetoLocal('sentadillas-$valor', 'Sentadillas', cantidad, valor),
      RetoLocal('brazos-$valor', 'Elevaciones de brazos', cantidad, valor),
    ];
  }
}
