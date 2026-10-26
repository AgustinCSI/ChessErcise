import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';
import '../theme/app_theme.dart';

class PuzzleMoves extends StatefulWidget {
  const PuzzleMoves({super.key, required this.controller});
  final PuzzleController controller;

  @override
  State<PuzzleMoves> createState() => _PuzzleMovesState();
}

class _PuzzleMovesState extends State<PuzzleMoves> {
  final _seleccion = GlobalKey();

  @override
  void initState() {
    super.initState();
    _seguirSeleccion();
  }

  @override
  void didUpdateWidget(covariant PuzzleMoves oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seguirSeleccion();
  }

  void _seguirSeleccion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _seleccion.currentContext;
      if (mounted && context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.7,
          duration: const Duration(milliseconds: 180),
        );
      }
    });
  }

  Widget _boton(int vista, String etiqueta, Widget child) => Semantics(
    selected: widget.controller.vista == vista,
    child: TextButton(
      key: widget.controller.vista == vista ? _seleccion : null,
      onPressed: () => widget.controller.irA(vista),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: widget.controller.vista == vista
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Tooltip(
        message: etiqueta,
        child: Semantics(label: etiqueta, excludeSemantics: true, child: child),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final moves = widget.controller.historial;
    return Container(
      height: 48,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.colorTiraJugadas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _boton(
              0,
              'Posición inicial',
              const Icon(Icons.first_page, size: 20),
            ),
            for (final move in moves) ...[
              if (move.lado == Side.white || move.vista == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '${move.numero}${move.lado == Side.white ? '.' : '...'}',
                  ),
                ),
              _boton(
                move.vista,
                '${move.numero}${move.lado == Side.white ? '.' : '...'} ${move.san}',
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (RegExp(r'^[KQRBN]').hasMatch(move.san)) ...[
                      Image(
                        image:
                            PieceSet.cburnett.assets[Piece(
                              role: Role.fromChar(move.san[0].toLowerCase())!,
                              color: move.lado,
                            ).kind]!,
                        width: 22,
                        height: 22,
                      ),
                      Text(move.san.substring(1)),
                    ] else
                      Text(move.san),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
