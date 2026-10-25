import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../data/lichess_puzzles_service.dart';
import '../../../models/puzzle_diario.dart';
import 'puzzle_screen.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key, this.service});

  final LichessPuzzlesService? service;

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  late final _service = widget.service ?? LichessPuzzlesService();
  late Future<PuzzleDiario> _puzzle;
  CancelToken? _cancel;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _cancel?.cancel();
    _cancel = CancelToken();
    _puzzle = _service.obtenerDiario(cancelToken: _cancel);
  }

  @override
  void dispose() {
    _cancel?.cancel();
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('El desafío de hoy')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FutureBuilder<PuzzleDiario>(
              future: _puzzle,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando el puzzle de Lichess…'),
                    ],
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  final error = snapshot.error;
                  final mensaje =
                      error is DioException && error.response?.statusCode == 429
                      ? 'Lichess recibió demasiadas solicitudes. Espera un minuto antes de reintentar.'
                      : error is FormatException
                      ? 'El puzzle recibido no se pudo interpretar.'
                      : 'No se pudo cargar el puzzle. Revisa tu conexión.';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mensaje, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(_cargar),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  );
                }
                final puzzle = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.extension_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Hero(
                          tag: 'puzzle-${puzzle.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              'Puzzle #${puzzle.id} · ${puzzle.rating} Elo',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Encuentra la mejor secuencia. El rival responderá automáticamente.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PuzzleScreen(puzzle: puzzle),
                            ),
                          ),
                          child: const Text('Resolver puzzle'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fuente: Lichess · No requiere cuenta Lichess',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
