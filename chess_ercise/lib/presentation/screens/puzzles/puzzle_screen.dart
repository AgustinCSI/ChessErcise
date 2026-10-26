import 'dart:convert';
import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../../logic/puzzle_controller.dart';
import '../../../models/puzzle_diario.dart';
import '../../widgets/tablero_widget.dart';
import '../../widgets/puzzle_toolbar.dart';
import '../../widgets/player_info.dart';
import '../../widgets/puzzle_moves.dart';
import '../../theme/app_theme.dart';
import '../../widgets/puzzle_status.dart';
import '../../providers/puzzles_provider.dart';
import '../../widgets/puzzle_save_status.dart';
import 'puzzle_summary_screen.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key, required this.puzzle, this.diario});

  final PuzzleDiario puzzle;
  final PuzzlesProvider? diario;

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late final _controller = PuzzleController(
    widget.puzzle,
    progreso: widget.diario?.progresoPara(widget.puzzle),
  );
  bool _revisar = false;
  String? _ultimoGuardado;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_guardar);
    Future.microtask(() {
      if (mounted) _guardar();
    });
  }

  void _guardar() {
    final progreso = _controller.estadoGuardado;
    final raw = jsonEncode(progreso.toJson());
    if (raw == _ultimoGuardado) return;
    _ultimoGuardado = raw;
    widget.diario?.guardar(widget.puzzle, progreso);
  }

  @override
  void dispose() {
    _controller.removeListener(_guardar);
    _controller.dispose();
    super.dispose();
  }

  Widget _encabezado(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Hero(
        tag: 'puzzle-${widget.puzzle.id}',
        child: Material(
          color: Colors.transparent,
          child: Text(
            'Puzzle #${widget.puzzle.id} · ${widget.puzzle.rating} Elo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        _controller.jugador == Side.white
            ? 'Juegas con blancas'
            : 'Juegas con negras',
      ),
    ],
  );

  Widget _estado(BuildContext context) => PuzzleStatus(
    mensaje: _controller.mensajeVisible,
    completado: _controller.completado,
  );

  Widget _tablero() => LayoutBuilder(
    builder: (context, constraints) {
      // Tablero y jugador forman una sola unidad, sin espacios flexibles entre sí.
      const pie = 96.0;
      final size = math.max(
        0.0,
        math.min(constraints.maxWidth, constraints.maxHeight - pie),
      );
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: math.min(constraints.maxWidth, math.max(size, 200)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableroWidget(puzzle: _controller, size: size),
              const SizedBox(height: 8),
              const SizedBox(height: 48, child: PlayerInfo()),
              const SizedBox(height: 8),
              Row(
                key: const ValueKey('puzzle-counters'),
                children: [
                  Expanded(
                    child: _contador(
                      'Errores: ${_controller.errores}',
                      Icons.close,
                      AppTheme.colorErrores,
                      AppTheme.textoErrores,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _contador(
                      'Pistas: ${_controller.pistasUsadas}',
                      Icons.lightbulb_outline,
                      AppTheme.colorPistas,
                      AppTheme.textoPistas,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _contador(String texto, IconData icono, Color fondo, Color color) =>
      Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icono, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  texto,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final contenido = _controller.finalizado && !_revisar
          ? PuzzleSummaryScreen(
              controller: _controller,
              onReview: () => setState(() => _revisar = true),
            )
          : _juego(context);
      final diario = widget.diario;
      if (diario == null) return contenido;
      return Column(
        children: [
          PuzzleSaveStatus(diario: diario),
          Expanded(child: contenido),
        ],
      );
    },
  );

  Widget _juego(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Puzzle diario'),
      actions: [
        if (_controller.finalizado)
          IconButton(
            tooltip: 'Ver resumen',
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () => setState(() => _revisar = false),
          ),
      ],
    ),
    bottomNavigationBar: PuzzleToolbar(controller: _controller),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              // En ventanas anchas la información comparte la altura del tablero.
              final horizontal =
                  constraints.maxWidth >= 600 &&
                  constraints.maxWidth > constraints.maxHeight;
              if (horizontal) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              PuzzleMoves(controller: _controller),
                              const SizedBox(height: 8),
                              Expanded(child: _tablero()),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 280,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: 280,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _encabezado(context),
                                    const SizedBox(height: 20),
                                    _estado(context),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _encabezado(context),
                      const SizedBox(height: 8),
                      _estado(context),
                      const SizedBox(height: 4),
                      PuzzleMoves(controller: _controller),
                      const SizedBox(height: 8),
                      Expanded(child: _tablero()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
