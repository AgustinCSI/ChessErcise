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
    this.construirSesion,
  }) : assert(supabaseDisponible != null || inicializacion != null);

  final bool? supabaseDisponible;
  final Future<bool>? inicializacion;
  final Widget Function(ValueChanged<bool> onReady)? construirSesion;

  @override
  State<ChessErciseApp> createState() => _ChessErciseAppState();
}

class _ChessErciseAppState extends State<ChessErciseApp> {
  bool? _disponible;
  bool _introTerminada = false;
  bool _destinoListo = false;
  bool _entradaMostrada = false;

  void _intentarAbrir() {
    if (_introTerminada &&
        _disponible != null &&
        (!_disponible! || _destinoListo)) {
      _entradaMostrada = true;
    }
  }

  void _destinoPreparado(bool listo) {
    if (!mounted || _entradaMostrada) return;
    setState(() {
      _destinoListo = listo;
      _intentarAbrir();
    });
  }

  void _terminarIntro() {
    setState(() {
      _introTerminada = true;
      _intentarAbrir();
    });
  }

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
    if (mounted) {
      setState(() {
        _disponible = disponible;
        _intentarAbrir();
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ChessErcise',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro,
    home: Stack(
      fit: StackFit.expand,
      children: [
        if (_disponible == true)
          Offstage(
            key: const ValueKey('sesion'),
            offstage: !_entradaMostrada,
            child: TickerMode(
              enabled: _entradaMostrada,
              child: ExcludeFocus(
                excluding: !_entradaMostrada,
                child:
                    widget.construirSesion?.call(_destinoPreparado) ??
                    ChangeNotifierProvider(
                      create: (_) => AuthProvider(),
                      child: AuthGate(onReady: _destinoPreparado),
                    ),
              ),
            ),
          )
        else if (_disponible == false)
          Offstage(
            offstage: !_entradaMostrada,
            child: const Scaffold(
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
        IgnorePointer(
          ignoring: _entradaMostrada,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _entradaMostrada
                ? const SizedBox.expand(key: ValueKey('listo'))
                : IntroScreen(
                    key: const ValueKey('intro'),
                    esperando: _introTerminada,
                    onFinished: _terminarIntro,
                  ),
          ),
        ),
      ],
    ),
  );
}
