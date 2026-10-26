
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chess_ercise/config/app_config.dart';
import 'package:chess_ercise/data/lan_transporte_realtime.dart';
import 'package:chess_ercise/logic/partida_lan_controller.dart';
import 'package:chess_ercise/logic/partida_local_controller.dart';

Future<void> esperar(bool Function() listo) async {
  final limite = DateTime.now().add(const Duration(seconds: 20));
  while (!listo()) {
    if (DateTime.now().isAfter(limite)) {
      throw StateError('No llegó el estado esperado');
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}

void main() {
  test(
    'Dos clientes reales comparten partida por Realtime',
    () async {
      final a = SupabaseClient(AppConfig.supabaseUrl, AppConfig.supabaseKey);
      final b = SupabaseClient(AppConfig.supabaseUrl, AppConfig.supabaseKey);
      final host = PartidaLanController(
        transporte: TransporteRealtime(client: a),
      );
      final guest = PartidaLanController(
        transporte: TransporteRealtime(client: b),
      );
      try {
        await host.abrir('Prueba A');
        await guest.unirse('Prueba B', host.codigo);
        await esperar(() => host.conectado && guest.conectado);
        host.jugar(Move.parse('e2e4')!);
        await esperar(() => guest.partida.totalJugadas == 1);
        guest.jugar(Move.parse('d7d5')!);
        await esperar(() => host.partida.totalJugadas == 2 && !guest.pendiente);
        host.jugar(Move.parse('e4d5')!);
        await esperar(() => guest.partida.fase == FaseLocal.eligiendoReto);
        expect(guest.partida.posicion.fen, host.partida.posicion.fen);
        expect(
          guest.partida.opciones.map((e) => e.id),
          host.partida.opciones.map((e) => e.id),
        );
        host.elegirReto(host.partida.opciones.first.id);
        await esperar(() => guest.partida.fase == FaseLocal.respondiendo);
        guest.responder(true);
        await esperar(
          () => host.partida.fase == FaseLocal.ejercicio && !guest.pendiente,
        );
        guest.listo();
        await esperar(
          () => host.partida.fase == FaseLocal.jugando && !guest.pendiente,
        );
        expect(guest.partida.historial.length, 3);
        await guest.cerrar();
        await esperar(() => !host.conectado);
      } finally {
        await host.cerrar();
        await guest.cerrar();
        host.dispose();
        guest.dispose();
        await a.dispose();
        await b.dispose();
      }
    },
    skip: !AppConfig.configurado,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
