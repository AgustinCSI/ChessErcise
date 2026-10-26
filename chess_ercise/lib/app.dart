import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'presentation/screens/intro/intro_screen.dart';
import 'presentation/theme/app_theme.dart';

class ChessErciseApp extends StatefulWidget {
  const ChessErciseApp({
    super.key,
    this.supabaseDisponible,
    this.inicializacion,
  }) : assert(supabaseDisponible != null || inicializacion != null);

  final bool? supabaseDisponible;
  final Future<bool>? inicializacion;

  @override
  State<ChessErciseApp> createState() => _ChessErciseAppState();
}

class _ChessErciseAppState extends State<ChessErciseApp> {
  bool? _disponible;
  bool _introTerminada = false;

  @override
  void initState() {
    super.initState();
    _disponible = widget.supabaseDisponible;
    if (_disponible == null) {
      widget.inicializacion!.then(
        _terminarInicio,
        onError: (_) => _terminarInicio(false),
      );
    }
  }

  void _terminarInicio(bool disponible) {
    if (mounted) setState(() => _disponible = disponible);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ChessErcise',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro,
    home: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: !_introTerminada || _disponible == null
          ? IntroScreen(
              key: const ValueKey('intro'),
              esperando: _introTerminada && _disponible == null,
              onFinished: () => setState(() => _introTerminada = true),
            )
          : _disponible!
          ? ChangeNotifierProvider(
              key: const ValueKey('auth'),
              create: (_) => AuthProvider(),
              child: const AuthGate(),
            )
          : const Scaffold(
              key: ValueKey('configuracion'),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No se pudo iniciar Supabase.\n'
                      'Revisa SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY '
                      'y vuelve a iniciar la app.\n\n'
                      'Consulta las instrucciones en chess_ercise/README.md.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
    ),
  );
}
