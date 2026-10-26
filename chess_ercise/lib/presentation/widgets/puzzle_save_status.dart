import 'package:flutter/material.dart';

import '../providers/puzzles_provider.dart';

class PuzzleSaveStatus extends StatelessWidget {
  const PuzzleSaveStatus({super.key, required this.diario});
  final PuzzlesProvider diario;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: diario,
    builder: (context, _) {
      if (diario.errorGuardado == null && !diario.guardando) {
        return const SizedBox.shrink();
      }
      return SafeArea(
        bottom: false,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(diario.errorGuardado ?? 'Guardando progreso…'),
                ),
                if (diario.errorGuardado != null)
                  TextButton(
                    onPressed: diario.reintentarGuardado,
                    child: const Text('Reintentar'),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
