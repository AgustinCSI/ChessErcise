import 'package:flutter/material.dart';

import 'partida_local_screen.dart';

class LocalSetupScreen extends StatefulWidget {
  const LocalSetupScreen({super.key});

  @override
  State<LocalSetupScreen> createState() => _LocalSetupScreenState();
}

class _LocalSetupScreenState extends State<LocalSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _blancas = TextEditingController(text: 'Jugador 1');
  final _negras = TextEditingController(text: 'Jugador 2');

  @override
  void dispose() {
    _blancas.dispose();
    _negras.dispose();
    super.dispose();
  }

  String? _validar(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Escribe un nombre' : null;

  void _iniciar() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PartidaLocalScreen(
          nombreBlancas: _blancas.text.trim(),
          nombreNegras: _negras.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Multijugador local')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Frente a frente',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Un dispositivo sobre la mesa. Blancas en un extremo, negras en el otro. '
                  'El tablero queda fijo: no necesitas girar ni pasar el celular.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _blancas,
                  validator: _validar,
                  maxLength: 24,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Jugador de blancas',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _negras,
                  validator: _validar,
                  maxLength: 24,
                  onFieldSubmitted: (_) => _iniciar(),
                  decoration: const InputDecoration(
                    labelText: 'Jugador de negras',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Al capturar eliges un reto para tu rival. Puede aceptar y marcar Listo, '
                  'o rechazar y ver la animación «Tomar shot». '
                  'El tablero espera hasta que confirme. Catálogo inicial local; sin Wi-Fi ni segunda cuenta.',
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _iniciar,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Comenzar partida'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
