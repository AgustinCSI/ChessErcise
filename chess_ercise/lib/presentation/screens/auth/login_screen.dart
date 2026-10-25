import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _registro = false;
  bool _ocultar = true;
  String? _mensaje;
  bool _esError = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final auth = context.read<AuthProvider>();
    if (auth.cargando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _mensaje = null);
    final error = _registro
        ? await auth.registrar(_correo.text, _clave.text)
        : await auth.ingresar(_correo.text, _clave.text);
    if (!mounted) return;
    setState(() {
      _esError = error != null;
      _mensaje = error;
      if (error == null && _registro && auth.requiereConfirmacion) {
        _registro = false;
        _clave.clear();
        _confirmacion.clear();
        _mensaje =
            'Solicitud de registro recibida. Revisa tu correo para '
            'confirmar tu cuenta antes de ingresar.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.sports_esports_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ChessErcise',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mueve tus piezas. Activa tu cuerpo.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _registro ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _correo,
                        enabled: !cargando,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        validator: (value) {
                          final correo = value?.trim() ?? '';
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(correo)) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _clave,
                        enabled: !cargando,
                        obscureText: _ocultar,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: [
                          _registro
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        textInputAction: _registro
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!_registro) _enviar();
                        },
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          helperText: _registro
                              ? 'Al menos 6 caracteres.'
                              : null,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _ocultar
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            onPressed: cargando
                                ? null
                                : () => setState(() => _ocultar = !_ocultar),
                            icon: Icon(
                              _ocultar
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña.';
                          }
                          if (_registro && value.length < 6) {
                            return 'Usa al menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      if (_registro) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmacion,
                          enabled: !cargando,
                          obscureText: _ocultar,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            labelText: 'Repite la contraseña',
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _enviar(),
                          validator: (value) => value != _clave.text
                              ? 'Las contraseñas no coinciden.'
                              : null,
                        ),
                      ],
                      if (_mensaje != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _mensaje!,
                            style: TextStyle(
                              color: _esError
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: cargando ? null : _enviar,
                        child: cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_registro ? 'Crear cuenta' : 'Ingresar'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: cargando
                            ? null
                            : () {
                                setState(() {
                                  _registro = !_registro;
                                  _mensaje = null;
                                  _clave.clear();
                                  _confirmacion.clear();
                                  _form.currentState?.reset();
                                });
                              },
                        child: Text(
                          _registro
                              ? 'Ya tengo cuenta · Ingresar'
                              : 'Crear una cuenta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
