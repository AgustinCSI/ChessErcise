import 'package:flutter/material.dart';

import '../puzzles/daily_puzzle_screen.dart';

// Menú temporal: los modos multijugador se habilitarán en sus bloques.
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
            ],
          ),
        ),
      ),
    );
  }
}
