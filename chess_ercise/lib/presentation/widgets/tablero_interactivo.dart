import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Extraído del TableroWidget existente: un solo controlador visual para ambos modos.
class TableroInteractivo extends StatefulWidget {
  const TableroInteractivo({
    super.key,
    required this.size,
    required this.posicion,
    required this.jugador,
    required this.orientacion,
    required this.ultimaJugada,
    required this.puedeMover,
    required this.onMove,
    this.frenteAFrente = false,
    this.pista,
  });

  final double size;
  final Position posicion;
  final Side jugador;
  final Side orientacion;
  final Move? ultimaJugada;
  final bool puedeMover;
  final void Function(Move) onMove;
  final bool frenteAFrente;
  final Square? pista;

  @override
  State<TableroInteractivo> createState() => _TableroInteractivoState();
}

class _TableroInteractivoState extends State<TableroInteractivo> {
  late final ChessboardController _tablero;

  GameData _datos() => GameData(
    fen: widget.posicion.fen,
    playerSide: !widget.puedeMover
        ? PlayerSide.none
        : widget.jugador == Side.white
        ? PlayerSide.white
        : PlayerSide.black,
    sideToMove: widget.posicion.turn,
    validMoves: makeLegalMoves(widget.posicion),
    lastMove: widget.ultimaJugada,
    kingSquareInCheck: widget.posicion.isCheck
        ? widget.posicion.board.kingOf(widget.posicion.turn)
        : null,
  );

  @override
  void initState() {
    super.initState();
    _tablero = ChessboardController(game: _datos());
  }

  @override
  void didUpdateWidget(covariant TableroInteractivo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tablero.updatePosition(_datos());
  }

  @override
  void dispose() {
    _tablero.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Chessboard(
    size: widget.size,
    controller: _tablero,
    orientation: widget.orientacion,
    settings: ChessboardSettings(
      colorScheme: AppTheme.tablero,
      pieceOrientationBehavior: widget.frenteAFrente
          ? PieceOrientationBehavior.opponentUpsideDown
          : PieceOrientationBehavior.facingUser,
    ),
    shapes: {
      if (widget.pista case final square?)
        Circle(color: Theme.of(context).colorScheme.primary, orig: square),
    },
    onMove: (move, {viaDragAndDrop}) => widget.onMove(move),
  );
}
