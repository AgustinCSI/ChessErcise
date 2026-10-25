import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

// Pantalla provisional para comprobar la sesión; los modos se implementan después.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('ChessErcise')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                '¡Sesión iniciada!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(Supabase.instance.client.auth.currentUser?.email ?? ''),
              const SizedBox(height: 16),
              const Text(
                'Próximamente: partidas con amigos y puzzle diario.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: auth.cargando
                    ? null
                    : () async {
                        final error = await auth.salir();
                        if (!context.mounted || error == null) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      },
                icon: const Icon(Icons.logout),
                label: Text(
                  auth.cargando ? 'Cerrando sesión…' : 'Cerrar sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
