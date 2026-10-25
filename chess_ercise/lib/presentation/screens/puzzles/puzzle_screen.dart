import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../../logic/puzzle_controller.dart';
import '../../../models/puzzle_diario.dart';
import '../../widgets/tablero_widget.dart';
import '../../widgets/puzzle_toolbar.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key, required this.puzzle});

  final PuzzleDiario puzzle;

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late final _controller = PuzzleController(widget.puzzle);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Puzzle diario')),
    bottomNavigationBar: PuzzleToolbar(controller: _controller),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'puzzle-${widget.puzzle.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        'Puzzle #${widget.puzzle.id} · ${widget.puzzle.rating} Elo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.jugador == Side.white
                        ? 'Juegas con blancas'
                        : 'Juegas con negras',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) => TableroWidget(
                      puzzle: _controller,
                      size: constraints.maxWidth,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _controller.progreso),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _controller.completado
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(_controller.mensajeVisible),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jugada ${_controller.vista}/${_controller.totalJugadas} · Errores: ${_controller.errores}',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _controller.reiniciar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Volver a intentarlo'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puzzle de Lichess · El progreso se conserva solo en esta pantalla.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
