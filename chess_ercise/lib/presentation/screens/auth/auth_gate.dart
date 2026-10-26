import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile/profile_gate.dart';
import 'login_screen.dart';

// La sesión decide qué pantalla se muestra; no navegamos manualmente al entrar.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.onReady});
  final ValueChanged<bool>? onReady;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final _auth = Supabase.instance.client.auth;
  late final Stream<AuthState> _cambios = _auth.onAuthStateChange;

  String? _usuario;
  bool? _ultimoAviso;

  void _avisarPreparado(bool listo) {
    if (_ultimoAviso == listo) return;
    _ultimoAviso = listo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ultimoAviso == listo) widget.onReady?.call(listo);
    });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: _cambios,
    builder: (context, snapshot) {
      final usuario = _auth.currentSession == null
          ? null
          : _auth.currentUser!.id;
      if (_ultimoAviso == null || usuario != _usuario) {
        _usuario = usuario;
        _avisarPreparado(usuario == null);
      }
      return Column(
        children: [
          if (snapshot.hasError)
            const SafeArea(
              bottom: false,
              child: MaterialBanner(
                content: Text(
                  'No se pudo actualizar la sesión. Revisa tu conexión.',
                ),
                actions: [SizedBox.shrink()],
              ),
            ),
          Expanded(
            child: _auth.currentSession == null
                ? const LoginScreen()
                : ProfileGate(
                    key: ValueKey(_auth.currentUser!.id),
                    userId: _auth.currentUser!.id,
                    onReady: _avisarPreparado,
                  ),
          ),
        ],
      );
    },
  );
}
