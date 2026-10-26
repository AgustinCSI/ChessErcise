import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../logic/partida_local_controller.dart';
import '../../models/reto_local.dart';
import '../theme/app_theme.dart';
import 'player_info.dart';

// La misma zona se construye para ambos jugadores; la pantalla gira la superior.
class PanelJugadorLocal extends StatelessWidget {
  static const _textoPartida = TextStyle(
    color: Color(0xFF171117),
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  const PanelJugadorLocal({
    super.key,
    required this.partida,
    required this.lado,
    required this.nombre,
    required this.onSalir,
    required this.onReiniciar,
    this.onElegirReto,
    this.onResponder,
    this.onListo,
    this.mostrarFicha = true,
    this.habilitado = true,
    this.textoReinicio = 'Nueva partida',
    this.soloLectura = false,
    this.mensajeEstado,
    this.imagen,
  });

  final PartidaLocalController partida;
  final Side lado;
  final String nombre;
  final VoidCallback onSalir;
  final VoidCallback onReiniciar;
  final void Function(String)? onElegirReto;
  final void Function(bool)? onResponder;
  final VoidCallback? onListo;
  final bool mostrarFicha;
  final bool habilitado;
  final String textoReinicio;
  // Wi-Fi muestra la ficha rival sin permitir actuar en su nombre.
  final bool soloLectura;
  final String? mensajeEstado;
  final ImageProvider? imagen;

  String get _color => lado == Side.white ? 'Blancas' : 'Negras';

  bool get _activo => switch (partida.fase) {
    FaseLocal.jugando => partida.posicion.turn == lado,
    FaseLocal.eligiendoReto => partida.capturador == lado,
    FaseLocal.respondiendo ||
    FaseLocal.ejercicio ||
    FaseLocal.shot => partida.retado == lado,
    FaseLocal.finalizada => true,
  };

  // Una tarjeta para elegir, responder y mostrar el ejercicio en curso.
  // La imagen conserva su canal alfa: no se le agrega un fondo blanco.
  Widget _tarjeta({
    required String texto,
    required Color color,
    RetoLocal? reto,
    VoidCallback? onTap,
    bool shot = false,
    bool textoClaro = false,
  }) {
    final contenido = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shot)
            const SizedBox(
              height: 56,
              child: Icon(
                Icons.local_bar_rounded,
                size: 48,
                color: Color(0xFFFFD689),
              ),
            )
          else if (reto != null)
            Image.asset(
              reto.imagen,
              height: 56,
              width: double.infinity,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          const SizedBox(height: 4),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textoClaro ? Colors.white : _textoPartida.color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: onTap != null,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: contenido),
      ),
    );
  }

  Widget _espera(String mensaje) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(mensaje, textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const _PuntosEspera(),
    ],
  );

  Widget _botonRespuesta(BuildContext context, bool acepta) => _tarjeta(
    texto: acepta ? 'Aceptar reto' : 'Rechazar',
    color: acepta ? AppTheme.colorAceptar : AppTheme.colorRechazar,
    reto: acepta ? partida.reto : null,
    shot: !acepta,
    textoClaro: true,
    onTap: () => onResponder != null
        ? onResponder!(acepta)
        : partida.responder(lado, acepta: acepta),
  );

  Widget _acciones(BuildContext context) {
    if (mensajeEstado != null) return _espera(mensajeEstado!);
    if (soloLectura) {
      final mensaje = switch (partida.fase) {
        FaseLocal.jugando => _activo ? 'Su turno' : 'Espera tu jugada',
        FaseLocal.eligiendoReto =>
          _activo
              ? 'Está eligiendo un reto para ti.'
              : 'Espera que elijas un reto.',
        FaseLocal.respondiendo =>
          _activo
              ? 'Está decidiendo si acepta el reto.'
              : 'Espera tu respuesta.',
        FaseLocal.ejercicio =>
          _activo
              ? 'Está realizando el ejercicio.'
              : 'Espera que termines el ejercicio.',
        FaseLocal.shot =>
          _activo
              ? 'Rechazó el reto. Espera a que continúe.'
              : 'Espera tu confirmación.',
        FaseLocal.finalizada => partida.resultado,
      };
      return partida.fase == FaseLocal.finalizada
          ? Text(mensaje, textAlign: TextAlign.center)
          : _espera(mensaje);
    }
    switch (partida.fase) {
      case FaseLocal.jugando:
        return Text(
          _activo
              ? 'Tu turno${partida.posicion.isCheck ? ' · Jaque' : ''}'
              : 'Turno del rival',
          style: _textoPartida,
        );
      case FaseLocal.eligiendoReto:
        if (!_activo) {
          return _espera('Tu rival está eligiendo un reto para ti.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Capturaste ${RetoLocal.nombreDe(partida.piezaCapturada!)} · '
              '${RetoLocal.valorDe(partida.piezaCapturada!)} '
              '${RetoLocal.valorDe(partida.piezaCapturada!) == 1 ? 'punto' : 'puntos'}. Elige el reto:',
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < partida.opciones.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _tarjeta(
                      reto: partida.opciones[i],
                      texto:
                          '${partida.opciones[i].titulo} · ${partida.opciones[i].indicacion}',
                      color: const Color(0xFFF3A4B8),
                      onTap: () => onElegirReto != null
                          ? onElegirReto!(partida.opciones[i].id)
                          : partida.elegirReto(lado, partida.opciones[i].id),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      case FaseLocal.respondiendo:
        if (!_activo) return _espera('Espera la respuesta de tu rival.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${partida.reto!.titulo} · ${partida.reto!.indicacion}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _botonRespuesta(context, false)),
                const SizedBox(width: 16),
                Expanded(child: _botonRespuesta(context, true)),
              ],
            ),
          ],
        );
      case FaseLocal.ejercicio:
        if (!_activo) return _espera('Tu rival está realizando el reto.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: .72,
                child: _tarjeta(
                  texto:
                      '${partida.reto!.titulo} · ${partida.reto!.indicacion}',
                  reto: partida.reto,
                  color: AppTheme.colorAceptar,
                  textoClaro: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onListo ?? () => partida.listo(lado),
              child: const Text('Listo'),
            ),
          ],
        );
      case FaseLocal.shot:
        if (!_activo) return _espera('Tu rival rechazó el reto.');
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
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: .72,
                  child: _tarjeta(
                    texto: 'Tomar shot',
                    color: AppTheme.colorRechazar,
                    shot: true,
                    textoClaro: true,
                  ),
                ),
              ),
            ),
            FilledButton(
              onPressed: onListo ?? () => partida.listo(lado),
              child: const Text('Continuar'),
            ),
          ],
        );
      case FaseLocal.finalizada:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(partida.resultado),
            FilledButton(onPressed: onReiniciar, child: Text(textoReinicio)),
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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mostrarFicha)
              Row(
                children: [
                  Expanded(
                    child: PlayerInfo(
                      nombre: '$nombre · $_color',
                      imagen: imagen,
                      estiloNombre: _textoPartida,
                    ),
                  ),
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
                child: AbsorbPointer(
                  absorbing: !habilitado,
                  child: DefaultTextStyle.merge(
                    style: _textoPartida,
                    child: _acciones(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Solo este pequeño indicador se redibuja en cada fotograma.
class _PuntosEspera extends StatefulWidget {
  const _PuntosEspera();

  @override
  State<_PuntosEspera> createState() => _PuntosEsperaState();
}

class _PuntosEsperaState extends State<_PuntosEspera>
    with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animacion.stop();
      _animacion.value = 0;
    } else if (!_animacion.isAnimating) {
      _animacion.repeat();
    }
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _animacion,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Transform.translate(
              key: ValueKey('punto-espera-$i'),
              offset: Offset(
                0,
                MediaQuery.disableAnimationsOf(context)
                    ? 0
                    : -3 * math.sin((_animacion.value - i / 6) * math.pi * 2),
              ),
              child: const Icon(
                Icons.circle,
                size: 10,
                color: Color(0xFF171117),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
