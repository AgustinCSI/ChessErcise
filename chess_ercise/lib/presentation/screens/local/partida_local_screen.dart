import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/partida_local_controller.dart';
import '../../providers/perfil_provider.dart';
import '../../widgets/panel_jugador_local.dart';
import '../../widgets/tablero_interactivo.dart';

class PartidaLocalScreen extends StatefulWidget {
  const PartidaLocalScreen({
    super.key,
    this.nombreBlancas = 'Jugador 1',
    this.nombreNegras = 'Jugador 2',
    this.partida,
  });

  final String nombreBlancas;
  final String nombreNegras;
  // Si se recibe un controller, quien lo creó conserva su propiedad y dispose.
  final PartidaLocalController? partida;

  @override
  State<PartidaLocalScreen> createState() => _PartidaLocalScreenState();
}

class _PartidaLocalScreenState extends State<PartidaLocalScreen> {
  late final _partida = widget.partida ?? PartidaLocalController();
  bool _saliendo = false;

  @override
  void dispose() {
    if (widget.partida == null) _partida.dispose();
    super.dispose();
  }

  Future<void> _salir(Side lado) async {
    if (_saliendo) return;
    final horizontal =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => RotatedBox(
        quarterTurns: (horizontal ? 1 : 0) + (lado == Side.black ? 2 : 0),
        child: AlertDialog(
          title: const Text('¿Salir de la partida?'),
          content: const Text(
            'Esta partida se guarda solo mientras está abierta.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir jugando'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || salir != true) return;
    setState(() => _saliendo = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Widget _panel(Side lado) {
    final perfil = context.watch<PerfilProvider?>();
    final nombre = lado == Side.white
        ? widget.nombreBlancas
        : widget.nombreNegras;
    final coincide =
        perfil?.perfil?.username.trim().toLowerCase() ==
        nombre.trim().toLowerCase();
    final foto = coincide ? perfil?.fotoBytes : null;
    return RotatedBox(
      quarterTurns: lado == Side.black ? 2 : 0,
      child: PanelJugadorLocal(
        partida: _partida,
        lado: lado,
        nombre: nombre,
        imagen: foto == null ? null : MemoryImage(foto),
        onSalir: () => _salir(lado),
        onReiniciar: _partida.reiniciar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _saliendo,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _salir(Side.white);
    },
    child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) => RotatedBox(
            // Las zonas ocupan los extremos del eje largo también en una tablet.
            quarterTurns: limites.maxWidth > limites.maxHeight ? 1 : 0,
            child: ListenableBuilder(
              listenable: _partida,
              builder: (context, _) => LayoutBuilder(
                builder: (context, espacio) {
                  final size = math.min(
                    espacio.maxWidth - 16,
                    espacio.maxHeight * .52,
                  );
                  // Usar todo el ancho evita que RotatedBox deje el juego
                  // pegado a un borde cuando el tablero es más pequeño.
                  return SizedBox(
                    width: espacio.maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: size,
                              child: _panel(Side.black),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              TableroInteractivo(
                                size: size,
                                posicion: _partida.posicion,
                                jugador: _partida.posicion.turn,
                                orientacion: Side.white,
                                frenteAFrente: true,
                                ultimaJugada: _partida.ultimaJugada,
                                puedeMover: _partida.puedeMover,
                                onMove: _partida.jugar,
                              ),
                              // El velo solo cubre el tablero; cada jugador
                              // conserva su panel orientado y sus acciones.
                              if (!_partida.puedeMover &&
                                  _partida.fase != FaseLocal.finalizada)
                                Positioned.fill(
                                  child: ColoredBox(
                                    key: const ValueKey('velo-reto-local'),
                                    color: Colors.black.withValues(alpha: .58),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SizedBox(
                              width: size,
                              child: _panel(Side.white),
                            ),
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
    ),
  );
}
