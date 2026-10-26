import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/perfil.dart';
import '../../providers/perfil_provider.dart';
import 'edit_profile_screen.dart';

// La pestaña muestra datos; el formulario vive en una ruta aparte.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();
    final perfil = provider.perfil!;
    final fecha = perfil.fechaNacimiento!;
    final foto = provider.fotoBytes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu perfil'),
        actions: const [SalirButton()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: Stack(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 56,
                              backgroundImage: foto == null
                                  ? null
                                  : MemoryImage(foto),
                              child: foto == null
                                  ? const Icon(Icons.person_outline, size: 56)
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IconButton.filled(
                              tooltip: 'Editar perfil',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: provider.guardando || provider.cargando
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const EditProfileScreen(),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    perfil.username,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (provider.errorFoto != null) ...[
                    const SizedBox(height: 8),
                    Text(provider.errorFoto!, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Nombre de usuario'),
                          subtitle: Text(perfil.username),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.cake_outlined),
                          title: const Text('Fecha de nacimiento'),
                          subtitle: Text(
                            '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: const Text('Género'),
                          subtitle: Text(Perfil.generos[perfil.genero]!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
