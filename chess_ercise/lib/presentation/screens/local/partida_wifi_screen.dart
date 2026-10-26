import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../logic/partida_lan_controller.dart';
import '../../../logic/partida_local_controller.dart';
import '../../widgets/panel_jugador_local.dart';
import '../../theme/app_theme.dart';
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
  bool _salir = false;
  PartidaLanController get _lan => widget.lan;

  // La vista es local: las actualizaciones de red no cambian el historial elegido.
  void _seleccionarVista(int indice) => setState(() {
    _vista = indice == _lan.partida.totalJugadas ? null : indice;
  });

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

  Widget _panel({required bool rival}) => PanelJugadorLocal(
    key: ValueKey(rival ? 'panel-wifi-rival' : 'panel-wifi-propio'),
    partida: _lan.partida,
    lado: rival ? _lan.lado.opposite : _lan.lado,
    nombre: rival ? _lan.rival : _lan.nombre,
    soloLectura: rival || _lan.partida.fase == FaseLocal.finalizada,
    habilitado: _lan.conectado && !_lan.pendiente,
    mensajeEstado: rival
        ? null
        : _lan.error ??
              (!_lan.conectado
                  ? 'Esperando a tu rival...'
                  : _lan.pendiente
                  ? 'Confirmando tu acción...'
                  : null),
    onSalir: _confirmarSalida,
    onReiniciar: () {},
    onElegirReto: _lan.elegirReto,
    onResponder: _lan.responder,
    onListo: _lan.listo,
  );

  Widget _historial() => TiraJugadas(
    historial: _lan.partida.historial,
    vista: _vista ?? _lan.partida.totalJugadas,
    onSelect: _seleccionarVista,
  );

  Widget _tablero(double size) {
    final juego = _lan.partida;
    final vista = (_vista ?? juego.totalJugadas).clamp(0, juego.totalJugadas);
    return Stack(
      children: [
        TableroInteractivo(
          size: size,
          posicion: juego.posicionEn(vista),
          jugador: _lan.lado,
          orientacion: _lan.lado,
          ultimaJugada: juego.jugadaEn(vista),
          puedeMover: _lan.puedeMover && _vista == null,
          onMove: _lan.jugar,
        ),
        // Durante la revision se ve la posicion historica con claridad.
        if (_vista == null &&
            juego.fase != FaseLocal.jugando &&
            juego.fase != FaseLocal.finalizada)
          Positioned.fill(
            child: ColoredBox(
              key: const ValueKey('velo-reto-wifi'),
              color: Colors.black.withValues(alpha: .58),
            ),
          ),
      ],
    );
  }

  Widget _juego(BoxConstraints espacio) {
    if (espacio.maxWidth > espacio.maxHeight) {
      final anchoPanel = math.min(360.0, espacio.maxWidth * .42);
      final size = math.max(
        0.0,
        math.min(espacio.maxWidth - anchoPanel - 16, espacio.maxHeight - 56),
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _historial(),
                const SizedBox(height: 8),
                _tablero(size),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: anchoPanel,
            child: Column(
              children: [
                Expanded(flex: 2, child: _panel(rival: true)),
                const SizedBox(height: 8),
                Expanded(flex: 3, child: _panel(rival: false)),
              ],
            ),
          ),
        ],
      );
    }
    final size = math.max(
      0.0,
      math.min(espacio.maxWidth, espacio.maxHeight * .45),
    );
    return Center(
      child: SizedBox(
        width: math.min(espacio.maxWidth, 600),
        child: Column(
          children: [
            Expanded(flex: 2, child: _panel(rival: true)),
            const SizedBox(height: 8),
            _historial(),
            const SizedBox(height: 8),
            _tablero(size),
            const SizedBox(height: 8),
            Expanded(flex: 3, child: _panel(rival: false)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _lan,
    builder: (context, _) => PopScope(
      canPop: _salir,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalida();
      },
      child: Scaffold(
        appBar: !_lan.conectado && _lan.partida.totalJugadas == 0
            ? AppBar(
                title: const Text('Local Wi-Fi'),
                leading: IconButton(
                  tooltip: 'Salir de la sala',
                  onPressed: _confirmarSalida,
                  icon: const Icon(Icons.arrow_back),
                ),
              )
            : null,
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
                          Text(
                            _lan.usaCodigo
                                ? 'Comparte este código con el otro navegador:'
                                : 'Comparte un acceso de la red Wi-Fi con tu rival:',
                          ),
                          if (_lan.usaCodigo)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SelectableText(
                                _lan.codigo,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge,
                              ),
                            ),
                          for (final ip in _lan.direcciones)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SelectableText(
                                '$ip:${_lan.puerto}/${_lan.codigo}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          Text(
                            _lan.usaCodigo
                                ? 'Ambos jugadores deben abrir la versión web y tener conexión a Internet.'
                                : 'Ambos dispositivos deben estar en la misma red. Usa la dirección de tu Wi-Fi si aparecen varias.',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, limites) => _juego(limites),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: _lan,
          builder: (context, _) {
            final total = _lan.partida.totalJugadas;
            final vista = (_vista ?? total).clamp(0, total);
            return Material(
              color: AppTheme.colorBarra,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Jugada anterior',
                      color: AppTheme.colorTexto,
                      disabledColor: AppTheme.colorTexto.withValues(alpha: .35),
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
                        foregroundColor: AppTheme.colorPrincipal,
                        disabledForegroundColor: AppTheme.colorTexto,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _vista != null ? 'Volver a la partida' : 'En vivo',
                          ),
                          if (_vista != null)
                            Text(
                              'Jugada $vista de $total',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Jugada siguiente',
                      color: AppTheme.colorTexto,
                      disabledColor: AppTheme.colorTexto.withValues(alpha: .35),
                      onPressed: vista < total
                          ? () => setState(
                              () => _vista = vista + 1 == total
                                  ? null
                                  : vista + 1,
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
    ),
  );
}
