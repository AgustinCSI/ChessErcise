import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../../logic/partida_lan_controller.dart';
import '../../../logic/partida_local_controller.dart';
import '../../widgets/panel_jugador_local.dart';
import '../../widgets/player_info.dart';
import '../../widgets/tablero_interactivo.dart';
import '../../widgets/tira_jugadas.dart';

class PartidaWifiScreen extends StatefulWidget {
  const PartidaWifiScreen({super.key, required this.lan});
  final PartidaLanController lan;
  @override
  State<PartidaWifiScreen> createState() => _PartidaWifiScreenState();
}

class _PartidaWifiScreenState extends State<PartidaWifiScreen> {
  int? _vista;
  bool _dialogo = false;
  bool _salir = false;
  PartidaLanController get _lan => widget.lan;
  bool get _miReto =>
      _lan.conectado &&
      switch (_lan.partida.fase) {
        FaseLocal.eligiendoReto => _lan.partida.capturador == _lan.lado,
        FaseLocal.respondiendo ||
        FaseLocal.ejercicio ||
        FaseLocal.shot => _lan.partida.retado == _lan.lado,
        _ => false,
      };

  @override
  void initState() {
    super.initState();
    _lan.addListener(_cambio);
    _cambio();
  }

  @override
  void dispose() {
    _lan.removeListener(_cambio);
    super.dispose();
  }

  void _cambio() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dialogo || !_miReto) return;
      _dialogo = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ListenableBuilder(
          listenable: _lan,
          builder: (context, _) {
            if (!_miReto) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              });
            }
            return PopScope(
              canPop: false,
              child: Dialog(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    maxHeight: MediaQuery.sizeOf(context).height * .8,
                  ),
                  child: PanelJugadorLocal(
                    partida: _lan.partida,
                    lado: _lan.lado,
                    nombre: _lan.nombre,
                    mostrarFicha: false,
                    habilitado: !_lan.pendiente,
                    onSalir: () {},
                    onReiniciar: () {},
                    onElegirReto: _lan.elegirReto,
                    onResponder: _lan.responder,
                    onListo: _lan.listo,
                  ),
                ),
              ),
            );
          },
        ),
      ).whenComplete(() {
        _dialogo = false;
        if (mounted) _cambio();
      });
    });
  }

  Future<void> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la sala?'),
        content: const Text('La conexión con tu rival se cerrará.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (!mounted || salir != true) return;
    setState(() => _salir = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Widget _estado() {
    final juego = _lan.partida;
    final texto =
        _lan.error ??
        (!_lan.conectado
            ? 'Esperando a tu rival…'
            : _vista != null
            ? 'Revisando jugadas. Vuelve a la partida para jugar.'
            : juego.fase == FaseLocal.finalizada
            ? juego.resultado
            : juego.fase != FaseLocal.jugando
            ? 'Reto en curso · Espera la confirmación.'
            : _lan.puedeMover
            ? 'Tu turno${juego.posicion.isCheck ? ' · Jaque' : ''}'
            : 'Turno de tu rival');
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(texto)),
    );
  }

  Widget _juego(BoxConstraints espacio) {
    final juego = _lan.partida;
    final vista = (_vista ?? juego.totalJugadas).clamp(0, juego.totalJugadas);
    final size = math.max(
      0.0,
      math.min(espacio.maxWidth, espacio.maxHeight - 176),
    );
    return Center(
      child: SizedBox(
        width: math.max(size, math.min(espacio.maxWidth, 220)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              child: PlayerInfo(
                nombre:
                    '${_lan.rival} · ${_lan.lado == Side.white ? 'Negras' : 'Blancas'}',
              ),
            ),
            const SizedBox(height: 8),
            TiraJugadas(
              historial: juego.historial,
              vista: vista,
              onSelect: (indice) => setState(
                () => _vista = indice == juego.totalJugadas ? null : indice,
              ),
            ),
            const SizedBox(height: 8),
            TableroInteractivo(
              size: size,
              posicion: juego.posicionEn(vista),
              jugador: _lan.lado,
              orientacion: _lan.lado,
              ultimaJugada: juego.jugadaEn(vista),
              puedeMover: _lan.puedeMover && _vista == null,
              onMove: _lan.jugar,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: PlayerInfo(
                nombre:
                    '${_lan.nombre} · ${_lan.lado == Side.white ? 'Blancas' : 'Negras'}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _salir,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _confirmarSalida();
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Local Wi-Fi'),
        leading: IconButton(
          tooltip: 'Salir de la sala',
          onPressed: _confirmarSalida,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _lan,
          builder: (context, _) {
            if (!_lan.conectado && _lan.partida.totalJugadas == 0) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_tethering, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          'Sala de ${_lan.nombre}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        _estado(),
                        const Text(
                          'Comparte un acceso de la red Wi-Fi con tu rival:',
                        ),
                        for (final ip in _lan.direcciones)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SelectableText(
                              '$ip:${_lan.puerto}/${_lan.codigo}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        const Text(
                          'Ambos dispositivos deben estar en la misma red. Usa la dirección de tu Wi-Fi si aparecen varias.',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, limites) {
                  if (limites.maxWidth > 760 &&
                      limites.maxWidth > limites.maxHeight) {
                    return Row(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, espacio) => _juego(espacio),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(width: 260, child: _estado()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _estado(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, espacio) => _juego(espacio),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _lan,
        builder: (context, _) {
          final total = _lan.partida.totalJugadas;
          final vista = _vista ?? total;
          return Material(
            color: Theme.of(context).colorScheme.primary,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: 'Jugada anterior',
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    onPressed: vista > 0
                        ? () => setState(() => _vista = vista - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  TextButton(
                    onPressed: _vista != null
                        ? () => setState(() => _vista = null)
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                    ),
                    child: Text(
                      _vista != null ? 'Volver a la partida' : 'En vivo',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Jugada siguiente',
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    onPressed: vista < total
                        ? () => setState(
                            () =>
                                _vista = vista + 1 == total ? null : vista + 1,
                          )
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
