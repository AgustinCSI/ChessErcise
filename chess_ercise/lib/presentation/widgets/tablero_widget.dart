import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../logic/puzzle_controller.dart';

class TableroWidget extends StatefulWidget {
  const TableroWidget({super.key, required this.puzzle, required this.size});

  final PuzzleController puzzle;
  final double size;

  @override
  State<TableroWidget> createState() => _TableroWidgetState();
}

class _TableroWidgetState extends State<TableroWidget> {
  late final ChessboardController _tablero;

  GameData _datos() {
    final puzzle = widget.puzzle;
    final posicion = puzzle.posicion;
    return GameData(
      fen: posicion.fen,
      playerSide: !puzzle.puedeMover
          ? PlayerSide.none
          : puzzle.jugador == Side.white
          ? PlayerSide.white
          : PlayerSide.black,
      sideToMove: posicion.turn,
      validMoves: makeLegalMoves(posicion),
      lastMove: puzzle.ultimaJugada,
      kingSquareInCheck: posicion.isCheck
          ? posicion.board.kingOf(posicion.turn)
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _tablero = ChessboardController(game: _datos());
    widget.puzzle.addListener(_actualizar);
  }

  void _actualizar() => _tablero.updatePosition(_datos());

  @override
  void didUpdateWidget(covariant TableroWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle != widget.puzzle) {
      oldWidget.puzzle.removeListener(_actualizar);
      widget.puzzle.addListener(_actualizar);
      _actualizar();
    }
  }

  @override
  void dispose() {
    widget.puzzle.removeListener(_actualizar);
    _tablero.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Chessboard(
    size: widget.size,
    controller: _tablero,
    orientation: widget.puzzle.jugador,
    onMove: (move, {viaDragAndDrop}) => widget.puzzle.jugar(move),
  );
}
