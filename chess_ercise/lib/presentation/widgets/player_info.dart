import 'package:flutter/material.dart';

// Datos provisionales: el perfil real podrá pasar nombre e imagen después.
class PlayerInfo extends StatelessWidget {
  const PlayerInfo({
    super.key,
    this.nombre = 'Tu nombre',
    this.imagen,
    this.estiloNombre,
  });

  final String nombre;
  final ImageProvider? imagen;
  final TextStyle? estiloNombre;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundImage: imagen,
        child: imagen == null ? const Icon(Icons.person_outline) : null,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: estiloNombre ?? Theme.of(context).textTheme.titleSmall,
        ),
      ),
    ],
  );
}
