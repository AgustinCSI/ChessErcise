import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    super.key,
    required this.onFinished,
    this.esperando = false,
  });

  final VoidCallback onFinished;
  final bool esperando;
  static const duracion = Duration(milliseconds: 2600);

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
    for (final nombre in [
      'ChessErcise_logo.png',
      ..._simbolos.map((s) => s.archivo),
    ]) {
      try {
        final data = await rootBundle.load('assets/intro_screen/$nombre');
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          targetWidth: nombre == 'ChessErcise_logo.png' ? 500 : 960,
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
    backgroundColor: AppTheme.colorFondo,
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
                        builder: (context, _) => CustomPaint(
                          painter: _IntroPainter(
                            _imagenes,
                            _reducido ? 0.6 : _animacion.value,
                          ),
                          child: _imagenes.containsKey('ChessErcise_logo.png')
                              ? null
                              : const Center(
                                  child: Text(
                                    'ChessErcise',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                        ),
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
    final logo = imagenes['ChessErcise_logo.png'];
    if (logo != null) {
      final entrada = ((progreso - 0.12) / 0.2).clamp(0.0, 1.0);
      // Reutilizar el wordmark exacto, sin sustituir la tipografía del logo.
      _dibujar(
        canvas,
        logo,
        const Rect.fromLTWH(60, 270, 380, 85),
        const Rect.fromLTWH(
          60,
          270,
          380,
          85,
        ).shift(Offset(0, 12 * (1 - entrada))),
        entrada,
      );
    }
    for (final simbolo in _simbolos) {
      final image = imagenes[simbolo.archivo];
      if (image == null) continue;
      final entrada = Curves.easeOutCubic.transform(
        ((progreso - simbolo.inicio) / 0.25).clamp(0.0, 1.0),
      );
      final salida = Curves.easeInCubic.transform(
        ((progreso - 0.8 - simbolo.inicio * 0.25) / 0.16).clamp(0.0, 1.0),
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
