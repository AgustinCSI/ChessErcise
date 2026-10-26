import 'package:dartchess/dartchess.dart';

class PuzzleDiario {
  const PuzzleDiario({
    required this.id,
    required this.rating,
    required this.posicionInicial,
    required this.solucion,
    this.ultimaJugada,
  });

  final String id;
  final int rating;
  final Position posicionInicial;
  final List<Move> solucion;
  final Move? ultimaJugada;

  Map<String, dynamic> toJson() => {
    'puzzle': {
      'id': id,
      'rating': rating,
      'fen': posicionInicial.fen,
      if (ultimaJugada != null) 'lastMove': ultimaJugada!.uci,
      'solution': solucion.map((m) => m.uci).toList(),
    },
  };

  factory PuzzleDiario.fromJson(Map<String, dynamic> json) {
    try {
      final puzzle = json['puzzle'] as Map<String, dynamic>;
      final id = puzzle['id'] as String;
      final rating = puzzle['rating'] as int;
      if (id.isEmpty || rating < 0) throw const FormatException();
      Position posicion;
      Move? ultima;
      if (puzzle['fen'] is String) {
        posicion = Chess.fromSetup(Setup.parseFen(puzzle['fen'] as String));
        final uci = puzzle['lastMove'];
        if (uci is String && uci.length >= 4) ultima = Move.parse(uci);
      } else {
        // Compatibilidad con respuestas sin FEN. initialPly es el índice
        // (desde cero) de la jugada preparatoria; hay que incluirla.
        final game = json['game'] as Map<String, dynamic>;
        final pgn = PgnGame.parsePgn(game['pgn'] as String);
        final cantidad = (puzzle['initialPly'] as int) + 1;
        final jugadas = pgn.moves.mainline().toList();
        if (cantidad < 1 || jugadas.length < cantidad) {
          throw const FormatException();
        }
        posicion = PgnGame.startingPosition(pgn.headers);
        for (final nodo in jugadas.take(cantidad)) {
          ultima = posicion.parseSan(nodo.san);
          if (ultima == null) throw const FormatException();
          posicion = posicion.play(ultima);
        }
      }
      final solucion = (puzzle['solution'] as List).map((value) {
        if (value is! String ||
            !RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(value)) {
          throw const FormatException();
        }
        return Move.parse(value)!;
      }).toList();
      if (solucion.isEmpty || solucion.length.isEven) {
        throw const FormatException();
      }
      // Comprobar todos los movimientos antes de ofrecer un puzzle jugable.
      var comprobacion = posicion;
      for (final move in solucion) {
        comprobacion = comprobacion.play(move);
      }
      return PuzzleDiario(
        id: id,
        rating: rating,
        posicionInicial: posicion,
        ultimaJugada: ultima,
        solucion: List.unmodifiable(solucion),
      );
    } catch (_) {
      throw const FormatException(
        'El puzzle recibido no tiene un formato válido.',
      );
    }
  }
}
