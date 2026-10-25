import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';

class PuzzleToolbar extends StatelessWidget {
  const PuzzleToolbar({super.key, required this.controller});

  final PuzzleController controller;

  Future<void> _mostrarSolucion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Ver la solución?'),
        content: const Text(
          'Esto cuenta como rendirse. Podrás recorrer la solución con las flechas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ver solución'),
          ),
        ],
      ),
    );
    if (context.mounted && confirmar == true) controller.rendirse();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Material(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Jugada anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.puedeRetroceder
                      ? controller.anterior
                      : null,
                ),
                IconButton(
                  tooltip: 'Jugada siguiente',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.puedeAvanzar
                      ? controller.siguiente
                      : null,
                ),
                IconButton(
                  tooltip: 'Pista: pieza que debes mover',
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: controller.puedeMover
                      ? controller.mostrarPista
                      : null,
                ),
                IconButton(
                  tooltip: 'Rendirse y ver solución',
                  icon: const Icon(Icons.flag),
                  onPressed: controller.rendido || controller.completado
                      ? null
                      : () => _mostrarSolucion(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
