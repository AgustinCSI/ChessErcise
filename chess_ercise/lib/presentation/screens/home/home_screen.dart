import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../puzzles/daily_puzzle_screen.dart';

// Menú temporal: los modos multijugador se habilitarán en sus bloques.
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
              Text(
                '¿Cómo quieres jugar?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Entrena tu mente, comparte el desafío.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DailyPuzzleScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.extension_outlined),
                      label: const Text('Puzzle diario'),
                    ),
                    const SizedBox(height: 12),
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('Multijugador local · Próximamente'),
                    ),
                    const SizedBox(height: 12),
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('Online con Lichess · Próximamente'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(Supabase.instance.client.auth.currentUser?.email ?? ''),
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
