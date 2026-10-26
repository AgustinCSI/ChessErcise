import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var disponible = false;
  if (AppConfig.configurado) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseKey,
      );
      disponible = true;
    } catch (_) {
      // La app explica cómo corregir la configuración sin mostrar credenciales.
    }
  }
  runApp(ChessErciseApp(supabaseDisponible: disponible));
}
