import 'dart:math' as math;

import 'package:flutter/material.dart';

class PuzzleStatus extends StatelessWidget {
  const PuzzleStatus({
    super.key,
    required this.mensaje,
    required this.completado,
  });

  final String mensaje;
  final bool completado;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = Theme.of(context).textTheme.bodyMedium!;
      // Reservar la altura del mensaje largo también cuando se muestra uno corto.
      // Se mide con el ancho y tamaño de texto reales, sin recortar el contenido.
      var height = 0.0;
      for (final text in [
        'Esa jugada es legal, pero no es la solución. Inténtalo otra vez.',
        'Revisando jugadas. Avanza hasta el final para continuar.',
        'Te rendiste. Usa las flechas para ver la solución.',
        mensaje,
      ]) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: math.max(1, constraints.maxWidth - 24));
        height = math.max(height, painter.height);
        painter.dispose();
      }
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height + 24,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: completado
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Semantics(liveRegion: true, child: Text(mensaje, style: style)),
      );
    },
  );
}
