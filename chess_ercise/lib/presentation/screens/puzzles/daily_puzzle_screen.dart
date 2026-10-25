import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/puzzles_provider.dart';
import '../../../models/puzzle_diario.dart';
import 'puzzle_screen.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key, this.diario});

  final PuzzlesProvider? diario;

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen>
    with WidgetsBindingObserver {
  late final _diario = widget.diario ?? context.read<PuzzlesProvider>();
  late Future<PuzzleDiario> _puzzle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargar();
  }

  void _cargar() {
    _puzzle = _diario.obtenerDiario();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(_cargar);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                final progreso = _diario.progresoPara(puzzle);
                final terminado =
                    progreso.rendido ||
                    progreso.indice == puzzle.solucion.length;
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
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PuzzleScreen(
                                  puzzle: puzzle,
                                  diario: _diario,
                                ),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                          child: Text(
                            terminado
                                ? 'Ver resumen'
                                : progreso.indice > 0
                                ? 'Continuar puzzle'
                                : 'Resolver puzzle',
                          ),
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
