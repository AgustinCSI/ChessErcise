import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';
import 'tablero_interactivo.dart';

// Adaptador del puzzle: conserva su API y comparte el tablero con el modo local.
class TableroWidget extends StatelessWidget {
  const TableroWidget({super.key, required this.puzzle, required this.size});

  final PuzzleController puzzle;
  final double size;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: puzzle,
    builder: (context, _) => TableroInteractivo(
      size: size,
      posicion: puzzle.posicionVisible,
      jugador: puzzle.jugador,
      orientacion: puzzle.jugador,
      ultimaJugada: puzzle.jugadaVisible,
      puedeMover: puzzle.puedeMover,
      pista: puzzle.pista,
      onMove: puzzle.jugar,
    ),
  );
}
