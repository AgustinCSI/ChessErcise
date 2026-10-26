import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'presentation/theme/app_theme.dart';

class ChessErciseApp extends StatelessWidget {
  const ChessErciseApp({super.key, required this.supabaseDisponible});

  final bool supabaseDisponible;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'ChessErcise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: supabaseDisponible
          ? const AuthGate()
          : const Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No se pudo iniciar Supabase.\n'
                      'Revisa SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY '
                      'y vuelve a iniciar la app.\n\n'
                      'Consulta las instrucciones en chess_ercise/README.md.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
    );
    if (!supabaseDisponible) return app;
    return ChangeNotifierProvider(create: (_) => AuthProvider(), child: app);
  }
}
