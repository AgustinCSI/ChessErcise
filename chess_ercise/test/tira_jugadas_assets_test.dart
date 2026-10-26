import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:chess_ercise/presentation/widgets/tira_jugadas.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _SinImagenesPiezas extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.contains('/cburnett/')) {
      throw FlutterError('Fallo de imagen simulado: $key');
    }
    return rootBundle.load(key);
  }
}

void main() {
  testWidgets('Las piezas de ambos colores siguen incluidas en el bundle', (
    tester,
  ) async {
    for (final imagen in PieceSet.cburnett.assets.values) {
      final datos = await rootBundle.load(imagen.keyName);
      expect(datos.lengthInBytes, greaterThan(0), reason: imagen.keyName);
    }
  });

  testWidgets(
    'Fallo de imagen conserva SAN, altura y selección sin ErrorWidget',
    (tester) async {
      final historial = <({int numero, Side lado, String san, int vista})>[];
      for (final lado in Side.values) {
        for (final san in ['Kf2', 'Qh3', 'Rd7', 'Bxf2+', 'Nc3']) {
          historial.add((
            numero: 1,
            lado: lado,
            san: san,
            vista: historial.length + 1,
          ));
        }
      }
      int? seleccion;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: DefaultAssetBundle(
            bundle: _SinImagenesPiezas(),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 260,
                  child: TiraJugadas(
                    historial: historial,
                    vista: 0,
                    onSelect: (vista) => seleccion = vista,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final letra in ['K', 'Q', 'R', 'B', 'N']) {
        expect(find.text(letra), findsNWidgets(2));
      }
      expect(find.text('xf2+'), findsNWidgets(2));
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.getSize(find.byType(TiraJugadas)).height, 48);
      expect(tester.takeException(), isNull);
      final alfil = find.byTooltip('1. Bxf2+');
      await tester.ensureVisible(alfil);
      await tester.tap(alfil);
      expect(seleccion, 4);
    },
  );
}
