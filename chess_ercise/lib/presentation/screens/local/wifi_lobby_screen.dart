import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/partida_lan_controller.dart';
import '../../providers/perfil_provider.dart';
import '../../widgets/tarjeta_modo.dart';
import 'partida_wifi_screen.dart';

class WifiLobbyScreen extends StatefulWidget {
  const WifiLobbyScreen({super.key});
  @override
  State<WifiLobbyScreen> createState() => _WifiLobbyScreenState();
}

class _WifiLobbyScreenState extends State<WifiLobbyScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _acceso = TextEditingController();
  bool _ocupado = false;
  bool _unirse = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Reutilizar el perfil ya cargado, sin otra petición ni cuenta para LAN.
    _nombre.text =
        context.read<PerfilProvider?>()?.perfil?.username ?? 'Jugador';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _acceso.dispose();
    super.dispose();
  }

  Future<void> _iniciar(bool unirse) async {
    if (_ocupado || !_form.currentState!.validate()) return;
    setState(() {
      _ocupado = true;
      _error = null;
    });
    final lan = PartidaLanController();
    try {
      if (unirse) {
        await lan.unirse(_nombre.text, _acceso.text);
      } else {
        await lan.abrir(_nombre.text);
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PartidaWifiScreen(lan: lan)),
      );
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo conectar. Comprueba la misma Wi-Fi y el acceso de la sala.',
        );
      }
    } finally {
      await lan.cerrar();
      lan.dispose();
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local Wi-Fi')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.wifi, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Juntos en la misma red',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Una persona crea la sala y comparte su acceso. La otra lo introduce desde su dispositivo. El anfitrión juega con blancas.',
                ),
                const SizedBox(height: 24),
                if (kIsWeb) ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Para jugar por Wi-Fi abre la app en dos dispositivos Android conectados a la misma red. El navegador permite revisar esta pantalla; no puede alojar la sala local.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nombre,
                  maxLength: 24,
                  decoration: const InputDecoration(labelText: 'Tu nombre'),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Escribe tu nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                TarjetaModo(
                  titulo: 'Crear sala',
                  descripcion: 'Comparte el acceso con tu rival.',
                  icono: Icons.add_circle_outline,
                  onTap: _ocupado || kIsWeb ? null : () => _iniciar(false),
                ),
                const SizedBox(height: 16),
                TarjetaModo(
                  titulo: 'Unirme a una sala',
                  descripcion: 'Usa el acceso que te comparte el anfitrión.',
                  icono: Icons.login,
                  onTap: _ocupado ? null : () => setState(() => _unirse = true),
                ),
                if (_unirse) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _acceso,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Acceso de la sala',
                      hintText: '192.168.1.5:45000/123456',
                    ),
                    validator: (valor) =>
                        _unirse && (valor == null || valor.trim().isEmpty)
                        ? 'Introduce el acceso de la sala'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _ocupado || kIsWeb ? null : () => _iniciar(true),
                    child: const Text('Conectar'),
                  ),
                ],
                if (_ocupado)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
