import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../logic/partida_local_controller.dart';
import '../../models/reto_local.dart';
import 'player_info.dart';

// La misma zona se construye para ambos jugadores; la pantalla gira la superior.
class PanelJugadorLocal extends StatelessWidget {
  const PanelJugadorLocal({
    super.key,
    required this.partida,
    required this.lado,
    required this.nombre,
    required this.onSalir,
    required this.onReiniciar,
  });

  final PartidaLocalController partida;
  final Side lado;
  final String nombre;
  final VoidCallback onSalir;
  final VoidCallback onReiniciar;

  String get _color => lado == Side.white ? 'Blancas' : 'Negras';

  bool get _activo => switch (partida.fase) {
    FaseLocal.jugando => partida.posicion.turn == lado,
    FaseLocal.eligiendoReto => partida.capturador == lado,
    FaseLocal.respondiendo ||
    FaseLocal.ejercicio ||
    FaseLocal.shot => partida.retado == lado,
    FaseLocal.finalizada => true,
  };

  Widget _acciones(BuildContext context) {
    switch (partida.fase) {
      case FaseLocal.jugando:
        return Text(
          _activo
              ? 'Tu turno${partida.posicion.isCheck ? ' · Jaque' : ''}'
              : 'Turno del rival',
          style: Theme.of(context).textTheme.titleMedium,
        );
      case FaseLocal.eligiendoReto:
        if (!_activo) {
          return const Text('Tu rival está eligiendo un reto para ti.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Capturaste ${RetoLocal.nombreDe(partida.piezaCapturada!)} · '
              '${RetoLocal.valorDe(partida.piezaCapturada!)} '
              '${RetoLocal.valorDe(partida.piezaCapturada!) == 1 ? 'punto' : 'puntos'}. Elige el reto:',
            ),
            for (final reto in partida.opciones)
              OutlinedButton(
                onPressed: () => partida.elegirReto(lado, reto.id),
                child: Text('${reto.titulo} · ${reto.indicacion}'),
              ),
          ],
        );
      case FaseLocal.respondiendo:
        if (!_activo) return const Text('Espera la respuesta de tu rival.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${partida.reto!.titulo} · ${partida.reto!.indicacion}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilledButton(
                  onPressed: () => partida.responder(lado, acepta: true),
                  child: const Text('Aceptar reto'),
                ),
                OutlinedButton(
                  onPressed: () => partida.responder(lado, acepta: false),
                  child: const Text('Rechazar'),
                ),
              ],
            ),
          ],
        );
      case FaseLocal.ejercicio:
        if (!_activo) return const Text('Tu rival está realizando el reto.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${partida.reto!.titulo} · ${partida.reto!.indicacion}'),
            FilledButton(
              onPressed: () => partida.listo(lado),
              child: const Text('Listo'),
            ),
          ],
        );
      case FaseLocal.shot:
        if (!_activo) return const Text('Tu rival rechazó el reto.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              builder: (context, valor, child) => Transform.rotate(
                angle: math.sin(valor * math.pi * 4) * .18,
                child: Transform.scale(scale: .8 + valor * .2, child: child),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_bar_outlined),
                  SizedBox(width: 8),
                  Flexible(child: Text('Tomar shot')),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => partida.listo(lado),
              child: const Text('Continuar'),
            ),
          ],
        );
      case FaseLocal.finalizada:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(partida.resultado),
            FilledButton(
              onPressed: onReiniciar,
              child: const Text('Nueva partida'),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _activo ? colores.primaryContainer : colores.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _activo ? colores.primary : colores.outlineVariant,
          width: _activo ? 2 : 1,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: PlayerInfo(nombre: '$nombre · $_color')),
                IconButton(
                  tooltip: 'Salir de la partida',
                  onPressed: onSalir,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey('${partida.fase.name}-$_activo'),
                child: _acciones(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
