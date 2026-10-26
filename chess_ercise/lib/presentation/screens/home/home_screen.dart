import 'package:flutter/material.dart';

import '../puzzles/daily_puzzle_screen.dart';
import '../local/local_modes_screen.dart';
import '../../widgets/tarjeta_modo.dart';

// El modo local comparte dispositivo; online se implementará después.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    TarjetaModo(
                      titulo: 'Puzzle diario',
                      descripcion: 'Un nuevo desafío para entrenar tu mente.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DailyPuzzleScreen(),
                        ),
                      ),
                      icono: Icons.extension_outlined,
                    ),
                    const SizedBox(height: 12),
                    TarjetaModo(
                      titulo: 'Multijugador local',
                      descripcion: 'Frente a frente o por la misma red Wi-Fi.',
                      icono: Icons.people_alt_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LocalModesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const TarjetaModo(
                      titulo: 'Online con Lichess',
                      descripcion:
                          'Próximamente · Juega con tu cuenta Lichess.',
                      icono: Icons.public,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
