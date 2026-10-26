import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../widgets/tarjeta_modo.dart';
import 'local_setup_screen.dart';
import 'wifi_lobby_screen.dart';

class LocalModesScreen extends StatelessWidget {
  const LocalModesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Multijugador local')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dos formas de jugar juntos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Elige cómo compartir la partida.'),
              const SizedBox(height: 28),
              TarjetaModo(
                titulo: 'Frente a frente',
                descripcion: 'Un celular o tablet entre ambos. Cada persona juega desde su lado.',
                icono: Icons.screen_rotation_alt,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const LocalSetupScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TarjetaModo(
                titulo: 'Local Wi-Fi',
                descripcion: kIsWeb
                    ? 'Dos navegadores con Internet. Crea una sala y comparte el código.'
                    : 'Dos dispositivos en la misma red. Crea una sala o únete a la de tu rival.',
                icono: Icons.wifi,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WifiLobbyScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
