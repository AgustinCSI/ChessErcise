import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/perfil_service.dart';

import 'package:provider/provider.dart';

import '../../../models/perfil.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';

class SalirButton extends StatelessWidget {
  const SalirButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return IconButton(
      tooltip: 'Cerrar sesión',
      icon: const Icon(Icons.logout),
      onPressed: auth.cargando
          ? null
          : () async {
              final error = await auth.salir();
              if (context.mounted && error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              }
            },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.inicializar = false,
    this.imagePicker,
  });
  final bool inicializar;
  final ImagePicker? imagePicker;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
    text: context.read<PerfilProvider>().perfil?.username ?? '',
  );
  late DateTime? _fecha = context
      .read<PerfilProvider>()
      .perfil
      ?.fechaNacimiento;
  late String? _genero =
      Perfil.generos.containsKey(context.read<PerfilProvider>().perfil?.genero)
      ? context.read<PerfilProvider>().perfil!.genero
      : null;
  String? _mensaje;
  bool _error = false;
  bool _seleccionando = false;
  Uint8List? _foto;

  Future<void> _seleccionarFoto() async {
    setState(() => _seleccionando = true);
    try {
      final picked = await (widget.imagePicker ?? ImagePicker()).pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (await picked.length() > PerfilService.maxFotoBytes) {
        throw const FormatException('La foto debe pesar como máximo 2 MB.');
      }
      final bytes = await picked.readAsBytes();
      PerfilService.tipoFoto(bytes);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 512,
        allowUpscaling: false,
      );
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (!mounted) return;
      setState(() {
        _foto = bytes;
        _mensaje = null;
      });
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _mensaje = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _mensaje = 'No se pudo abrir la imagen. Inténtalo otra vez.';
        });
      }
    } finally {
      if (mounted) setState(() => _seleccionando = false);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final provider = context.read<PerfilProvider>();
    if (provider.guardando || provider.cargando) return;
    FocusScope.of(context).unfocus();
    final error = await provider.guardar(
      _nombre.text,
      _fecha!,
      _genero!,
      foto: _foto,
    );
    if (!mounted) return;
    if (error == null && !widget.inicializar) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _error = error != null;
      _mensaje = error ?? 'Perfil actualizado.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();
    final ocupado = provider.guardando || provider.cargando || _seleccionando;
    final foto = _foto ?? provider.fotoBytes;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.inicializar,
        title: Text(
          widget.inicializar ? 'Completa tu perfil' : 'Editar perfil',
        ),
        actions: const [SalirButton()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: foto == null
                            ? null
                            : MemoryImage(foto),
                        child: foto == null
                            ? const Icon(Icons.person_outline, size: 40)
                            : null,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: ocupado ? null : _seleccionarFoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        _foto == null ? 'Cambiar foto' : 'Foto seleccionada',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.inicializar) ...[
                      const Text(
                        'Elige cómo te verán en ChessErcise. Completa estos datos para empezar.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                    TextFormField(
                      controller: _nombre,
                      enabled: !ocupado,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        helperText: '3–20 letras, números o guion bajo.',
                      ),
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: Perfil.validarUsername,
                    ),
                    const SizedBox(height: 16),
                    FormField<DateTime>(
                      validator: (_) => Perfil.fechaValida(_fecha)
                          ? null
                          : 'Selecciona una fecha válida.',
                      builder: (field) => InkWell(
                        onTap: ocupado
                            ? null
                            : () async {
                                final hoy = DateTime.now();
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: Perfil.fechaValida(_fecha)
                                      ? _fecha
                                      : DateTime(
                                          hoy.year - 18,
                                          hoy.month,
                                          hoy.day,
                                        ),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(
                                    hoy.year,
                                    hoy.month,
                                    hoy.day,
                                  ),
                                );
                                if (!mounted || selected == null) return;
                                setState(() => _fecha = selected);
                                field.didChange(selected);
                              },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento',
                            errorText: field.errorText,
                            enabled: !ocupado,
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            _fecha == null
                                ? 'Selecciona una fecha'
                                : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _genero,
                      decoration: const InputDecoration(labelText: 'Género'),
                      items: Perfil.generos.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: ocupado
                          ? null
                          : (value) => setState(() => _genero = value),
                      validator: (value) =>
                          value == null ? 'Selecciona una opción.' : null,
                    ),
                    if (_mensaje != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _mensaje!,
                          style: TextStyle(
                            color: _error
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: ocupado ? null : _guardar,
                      child: Text(
                        ocupado
                            ? 'Guardando…'
                            : widget.inicializar
                            ? 'Guardar y continuar'
                            : 'Guardar cambios',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
