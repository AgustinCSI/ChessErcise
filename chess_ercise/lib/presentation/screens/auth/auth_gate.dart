import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/session_navigator.dart';
import 'login_screen.dart';

// La sesión decide qué pantalla se muestra; no navegamos manualmente al entrar.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final _auth = Supabase.instance.client.auth;
  late final Stream<AuthState> _cambios = _auth.onAuthStateChange;

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: _cambios,
    builder: (context, snapshot) {
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
                : SessionNavigator(key: ValueKey(_auth.currentUser!.id)),
          ),
        ],
      );
    },
  );
}
