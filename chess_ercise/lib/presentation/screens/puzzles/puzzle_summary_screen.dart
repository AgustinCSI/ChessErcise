import 'package:flutter/material.dart';

import '../../../logic/puzzle_controller.dart';
import '../../providers/puzzles_provider.dart';
import '../../widgets/puzzle_routine.dart';

class PuzzleSummaryScreen extends StatelessWidget {
  const PuzzleSummaryScreen({
    super.key,
    required this.controller,
    required this.onReview,
    this.diario,
  });

  final PuzzleController controller;
  final VoidCallback onReview;
  final PuzzlesProvider? diario;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Resumen diario')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  controller.rendido ? Icons.flag : Icons.check_circle_outline,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.rendido ? 'Te rendiste' : '¡Puzzle resuelto!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Puzzle #${controller.puzzle.id} · ${controller.puzzle.rating} Elo',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Errores: ${controller.errores}'),
                        const SizedBox(height: 8),
                        Text('Pistas usadas: ${controller.pistasUsadas}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PuzzleRoutine(controller: controller, diario: diario),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onReview,
                  child: const Text('Revisar tablero'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
