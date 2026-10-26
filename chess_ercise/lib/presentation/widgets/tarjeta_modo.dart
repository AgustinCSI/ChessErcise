import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TarjetaModo extends StatelessWidget {
  const TarjetaModo({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    this.onTap,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? .72 : 1,
    child: Material(
      color: AppTheme.colorTarjeta,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icono, size: 36, color: const Color(0xFF681337)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.colorTexto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      style: const TextStyle(color: AppTheme.colorTexto),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Color(0xFF681337)),
            ],
          ),
        ),
      ),
    ),
  );
}
