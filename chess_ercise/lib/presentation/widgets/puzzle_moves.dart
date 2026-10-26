import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';
import 'tira_jugadas.dart';

// Adaptador conservado: la misma tira de jugadas se usa en puzzle y Wi-Fi.
class PuzzleMoves extends StatelessWidget {
  const PuzzleMoves({super.key, required this.controller});
  final PuzzleController controller;

  @override
  Widget build(BuildContext context) => TiraJugadas(
    historial: controller.historial,
    vista: controller.vista,
    onSelect: controller.irA,
  );
}
