import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/perfil_service.dart';
import '../../providers/perfil_provider.dart';
import '../home/session_navigator.dart';
import 'edit_profile_screen.dart';

// Componer pantallas según datos persistidos evita depender de una redirección.
class ProfileGate extends StatefulWidget {
  const ProfileGate({
    super.key,
    required this.userId,
    this.service,
    this.child,
    this.imagePicker,
  });
  final String userId;
  final PerfilService? service;
  final Widget? child;
  final ImagePicker? imagePicker;

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> with WidgetsBindingObserver {
  late final _perfil = PerfilProvider(
    userId: widget.userId,
    service: widget.service,
  );

  bool _comprobado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _perfil.cargar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _perfil.cargar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _perfil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _perfil,
    child: ListenableBuilder(
      listenable: _perfil,
      builder: (context, _) {
        if (!_perfil.cargando && _perfil.errorCarga == null) _comprobado = true;
        // El formulario conserva su State durante comprobaciones de segundo plano,
        // incluso si fallan. La consulta remota sigue bloqueando la interacción.
        return Stack(
          fit: StackFit.expand,
          children: [
            if (_perfil.perfil?.completo == true)
              widget.child ?? SessionNavigator(userId: widget.userId)
            else if (_comprobado)
              EditProfileScreen(
                inicializar: true,
                imagePicker: widget.imagePicker,
              )
            else
              Scaffold(
                appBar: AppBar(
                  title: const Text('Comprobando perfil'),
                  actions: const [SalirButton()],
                ),
                body: _perfil.errorCarga == null
                    ? const Center(child: CircularProgressIndicator())
                    : null,
              ),
            if (_comprobado && _perfil.cargando) ...[
              const ModalBarrier(dismissible: false, color: Colors.black12),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_perfil.errorCarga != null)
              Scaffold(
                appBar: AppBar(
                  title: const Text('Tu perfil'),
                  actions: const [SalirButton()],
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_perfil.errorCarga!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _perfil.cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
