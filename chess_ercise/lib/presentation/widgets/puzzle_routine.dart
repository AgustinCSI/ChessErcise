import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';
import '../../models/progreso_puzzle.dart';
import '../../models/reto_local.dart';
import '../providers/puzzles_provider.dart';

class PuzzleRoutine extends StatefulWidget {
  const PuzzleRoutine({super.key, required this.controller, this.diario});

  final PuzzleController controller;
  final PuzzlesProvider? diario;

  @override
  State<PuzzleRoutine> createState() => _PuzzleRoutineState();
}

class _PuzzleRoutineState extends State<PuzzleRoutine> {
  late ProgresoPuzzle _local = widget.controller.estadoGuardado;

  void _guardar(String id, {bool completada = false}) {
    final diario = widget.diario;
    if (diario != null) {
      diario.guardarRutina(
        widget.controller.puzzle,
        id,
        completada: completada,
      );
    } else {
      setState(() => _local = _local.conRutina(id, completada));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.diario ?? widget.controller,
    builder: (context, _) {
      final progreso =
          widget.diario?.progresoPara(widget.controller.puzzle) ?? _local;
      final total = progreso.repeticiones;
      final ejercicio = RetoLocal.catalogo.firstWhere(
        (e) => e.id == progreso.ejercicioId,
      );
      final reto = RetoLocal(ejercicio.id, ejercicio.titulo, '', total);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rutina de ejercicios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Errores: ${progreso.errores} × 5 = ${progreso.errores * 5} reps\n'
                'Pistas: ${progreso.pistas.length} × 2 = ${progreso.pistas.length * 2} reps',
              ),
              const SizedBox(height: 12),
              if (total == 0)
                const Text(
                  '¡Sin penalizaciones! No tienes ejercicios pendientes.',
                )
              else ...[
                Image.asset(reto.imagen, height: 112, fit: BoxFit.contain),
                const SizedBox(height: 12),
                if (progreso.rutinaCompletada)
                  Text(ejercicio.titulo, textAlign: TextAlign.center)
                else
                  DropdownButtonFormField<String>(
                    initialValue: progreso.ejercicioId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Ejercicio'),
                    items: [
                      // La regla del puzzle usa repeticiones, no segundos.
                      for (final e in RetoLocal.catalogo.where(
                        (e) => !e.porTiempo,
                      ))
                        DropdownMenuItem(value: e.id, child: Text(e.titulo)),
                    ],
                    onChanged: (id) {
                      if (id != null) _guardar(id);
                    },
                  ),
                const SizedBox(height: 12),
                Text(
                  '$total ${total == 1 ? 'repetición' : 'repeticiones'} en total',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (progreso.rutinaCompletada)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Rutina completada'),
                    ],
                  )
                else ...[
                  const Text('Cuando termines el ejercicio, pulsa Listo.'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _guardar(ejercicio.id, completada: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Listo'),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    },
  );
}
