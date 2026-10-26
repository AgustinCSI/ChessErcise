import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // La inicialización y la intro avanzan a la vez; Auth espera a que ambas terminen.
  runApp(ChessErciseApp(inicializacion: inicializarSupabase()));
}

Future<bool> inicializarSupabase() async {
  if (!AppConfig.configurado) return false;
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
    );
    return true;
  } catch (_) {
    return false;
  }
}
