import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    super.key,
    required this.onFinished,
    this.esperando = false,
  });

  final VoidCallback onFinished;
  final bool esperando;
  static const duracion = Duration(milliseconds: 1900);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final _animacion =
      AnimationController(vsync: this, duration: IntroScreen.duracion)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onFinished();
        });
  final _imagenes = <String, ui.Image>{};
  bool _iniciado = false;
  bool _reducido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducido = MediaQuery.disableAnimationsOf(context);
    if (!_iniciado) {
      _iniciado = true;
      _cargar();
    }
  }

  Future<void> _cargar() async {
    // Los PNG de Canva incluyen márgenes transparentes; el painter usa su área visible.
    for (final nombre in _simbolos.map((s) => s.archivo)) {
      try {
        final data = await rootBundle.load('assets/intro_screen/$nombre');
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          targetWidth: 960,
        );
        late ui.Image imagen;
        try {
          imagen = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
        if (!mounted) {
          imagen.dispose();
          return;
        }
        _imagenes[nombre] = imagen;
      } catch (_) {
        // Un recurso ausente no debe impedir abrir la app.
      }
    }
    if (!mounted) return;
    setState(() {});
    _animacion.duration = _reducido
        ? const Duration(milliseconds: 200)
        : IntroScreen.duracion;
    _animacion.forward();
  }

  @override
  void dispose() {
    _animacion.dispose();
    for (final imagen in _imagenes.values) {
      imagen.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = math.min(
                    460.0,
                    math.min(constraints.maxWidth, constraints.maxHeight),
                  );
                  return Semantics(
                    label: 'ChessErcise. Play. Move. Win.',
                    image: true,
                    child: SizedBox.square(
                      dimension: size,
                      child: AnimatedBuilder(
                        animation: _animacion,
                        builder: (context, _) {
                          final progreso = _reducido ? 0.6 : _animacion.value;
                          final tiempo =
                              progreso * IntroScreen.duracion.inMilliseconds;
                          final entradaTexto = ((tiempo - 312) / 520).clamp(
                            0.0,
                            1.0,
                          );
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomPaint(
                                painter: _IntroPainter(_imagenes, progreso),
                              ),
                              Positioned(
                                left: size * 0.12,
                                top: size * (0.54 + 0.024 * (1 - entradaTexto)),
                                width: size * 0.76,
                                height: size * 0.17,
                                child: Opacity(
                                  opacity: entradaTexto,
                                  child: ExcludeSemantics(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            child: Text(
                                              'CHESSERCISE',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -1.5,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: FittedBox(
                                              child: Text(
                                                'PLAY. MOVE. WIN.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 3.2,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 64,
            child: widget.esperando && _animacion.isCompleted
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(height: 8),
                      Text('Preparando tu cuenta…'),
                    ],
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

// Coordenadas sobre un lienzo de 500x500, como el logo original.
const _simbolos = [
  (
    archivo: 'PiezaRey.png',
    recorte: Rect.fromLTRB(702, 109, 1125, 972),
    destino: Rect.fromLTWH(112, 112, 65, 132),
    giro: 0.38,
    inicio: 0.0,
  ),
  (
    archivo: 'PiezaPeon.png',
    recorte: Rect.fromLTRB(742, 108, 1157, 977),
    destino: Rect.fromLTWH(179, 130, 58, 121),
    giro: 0.0,
    inicio: 0.04,
  ),
  (
    archivo: 'Mancuernas.png',
    recorte: Rect.fromLTRB(556, 135, 1390, 973),
    destino: Rect.fromLTWH(244, 163, 78, 78),
    giro: 0.75,
    inicio: 0.08,
  ),
  (
    archivo: 'Piezacaballo.png',
    recorte: Rect.fromLTRB(806, 109, 1278, 971),
    destino: Rect.fromLTWH(339, 130, 66, 121),
    giro: 0.18,
    inicio: 0.12,
  ),
  (
    archivo: 'CorazonLatido.png',
    recorte: Rect.fromLTRB(492, 111, 1498, 950),
    destino: Rect.fromLTWH(297, 94, 78, 65),
    giro: -0.3,
    inicio: 0.16,
  ),
  (
    archivo: 'PersonaEjers.png',
    recorte: Rect.fromLTRB(604, 111, 1510, 972),
    destino: Rect.fromLTWH(174, 360, 147, 140),
    giro: 0.0,
    inicio: 0.1,
  ),
];

class _IntroPainter extends CustomPainter {
  _IntroPainter(this.imagenes, this.progreso);
  final Map<String, ui.Image> imagenes;
  final double progreso;

  void _dibujar(
    Canvas canvas,
    ui.Image image,
    Rect source,
    Rect dest,
    double opacity,
  ) {
    canvas.drawImageRect(
      image,
      source,
      dest,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Color.fromRGBO(255, 255, 255, opacity),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 500);
    // Mantener 650 ms de entrada y 416 ms de salida; solo reducir la pausa central.
    final tiempo = progreso * IntroScreen.duracion.inMilliseconds;
    for (final simbolo in _simbolos) {
      final image = imagenes[simbolo.archivo];
      if (image == null) continue;
      final entrada = Curves.easeOutCubic.transform(
        ((tiempo - simbolo.inicio * 2600) / 650).clamp(0.0, 1.0),
      );
      final salida = Curves.easeInCubic.transform(
        ((tiempo - 1380 - simbolo.inicio * 650) / 416).clamp(0.0, 1.0),
      );
      final destino = simbolo.destino.shift(
        Offset(0, 35 * (1 - entrada) - 24 * salida),
      );
      canvas.save();
      canvas.translate(destino.center.dx, destino.center.dy);
      canvas.rotate(simbolo.giro + (1 - entrada) * -0.12);
      canvas.translate(-destino.center.dx, -destino.center.dy);
      _dibujar(
        canvas,
        image,
        Rect.fromLTRB(
          simbolo.recorte.left * image.width / 1920,
          simbolo.recorte.top * image.height / 1080,
          simbolo.recorte.right * image.width / 1920,
          simbolo.recorte.bottom * image.height / 1080,
        ),
        destino,
        entrada * (1 - salida),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IntroPainter oldDelegate) => true;
}
