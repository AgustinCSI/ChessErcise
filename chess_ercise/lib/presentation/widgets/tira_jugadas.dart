import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TiraJugadas extends StatefulWidget {
  const TiraJugadas({
    super.key,
    required this.historial,
    required this.vista,
    required this.onSelect,
  });
  final List<({int numero, Side lado, String san, int vista})> historial;
  final int vista;
  final void Function(int) onSelect;

  @override
  State<TiraJugadas> createState() => _TiraJugadasState();
}

class _TiraJugadasState extends State<TiraJugadas> {
  final _seleccion = GlobalKey();

  @override
  void initState() {
    super.initState();
    _seguirSeleccion();
  }

  @override
  void didUpdateWidget(covariant TiraJugadas oldWidget) {
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
    selected: widget.vista == vista,
    child: TextButton(
      key: widget.vista == vista ? _seleccion : null,
      onPressed: () => widget.onSelect(vista),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: widget.vista == vista
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
    final moves = widget.historial;
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
                        // Mantener SAN legible ante un fallo puntual del asset.
                        errorBuilder: (context, error, stackTrace) => SizedBox(
                          width: 22,
                          height: 22,
                          child: Center(
                            child: Text(
                              move.san[0],
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
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
