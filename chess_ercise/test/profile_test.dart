import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:chess_ercise/data/perfil_service.dart';
import 'package:chess_ercise/models/perfil.dart';
import 'package:chess_ercise/presentation/providers/auth_provider.dart';
import 'package:chess_ercise/presentation/providers/perfil_provider.dart';
import 'package:chess_ercise/presentation/screens/profile/profile_gate.dart';
import 'package:chess_ercise/presentation/screens/home/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chess_ercise/presentation/screens/profile/edit_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Perfil completo(String id, {String nombre = 'Jugador_1'}) => Perfil(
  id: id,
  username: nombre,
  fechaNacimiento: DateTime(2000, 2, 29),
  genero: 'prefiero_no_decir',
);

class FakePerfilService extends PerfilService {
  final Map<String, Perfil> perfiles = {};
  bool fallaCarga = false;
  bool duplicado = false;
  int consultas = 0;
  Completer<Perfil?>? pendiente;

  @override
  Future<Perfil?> obtener(String userId) async {
    consultas++;
    if (pendiente != null) return pendiente!.future;
    if (fallaCarga) throw Exception('offline');
    return perfiles[userId];
  }

  @override
  Future<Perfil> guardar(Perfil perfil) async {
    if (duplicado) {
      throw const PostgrestException(message: 'duplicate', code: '23505');
    }
    perfiles[perfil.id] = perfil;
    return perfil;
  }
}

class FakeAvatarService extends FakePerfilService {
  final borrados = <String>[];
  bool fallaFoto = false;
  @override
  Future<String> subirFoto(String userId, Uint8List bytes) async =>
      '$userId/new.png';
  @override
  Future<void> borrarFoto(String path) async {
    borrados.add(path);
  }

  @override
  Future<Uint8List> descargarFoto(String path) async {
    if (fallaFoto) throw Exception('offline');
    return Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
  }
}

class PendingImagePicker extends ImagePicker {
  final seleccion = Completer<XFile?>();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) => seleccion.future;
}

Widget harness(Widget child, GoTrueClient auth) => ChangeNotifierProvider(
  create: (_) => AuthProvider(auth: auth),
  child: MaterialApp(home: child),
);

void main() {
  testWidgets(
    'Setup keeps form and photo result through picker resume and saves both',
    (tester) async {
      final service = FakeAvatarService();
      final picker = PendingImagePicker();
      final auth = GoTrueClient();
      await tester.pumpWidget(
        harness(
          ProfileGate(
            userId: 'A',
            service: service,
            imagePicker: picker,
            child: const Text('Área privada'),
          ),
          auth,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Knight_photo');
      await tester.ensureVisible(find.text('Selecciona una fecha'));
      await tester.tap(find.text('Selecciona una fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prefiero no decirlo').last);
      await tester.pumpAndSettle();
      final formState = tester.state(find.byType(EditProfileScreen));
      await tester.ensureVisible(find.text('Cambiar foto'));
      await tester.tap(find.text('Cambiar foto'));
      await tester.pump();
      final check = Completer<Perfil?>();
      service.pendiente = check;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      // Hold verification open so the form must survive the loading frame.
      expect(tester.state(find.byType(EditProfileScreen)), same(formState));
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Knight_photo',
      );
      check.complete(null);
      await tester.pumpAndSettle();
      final bytes = io.File('web/favicon.png').readAsBytesSync();
      await tester.runAsync(() async {
        picker.seleccion.complete(
          XFile.fromData(bytes, name: 'avatar.png', mimeType: 'image/png'),
        );
        // Allow the engine image decoder to finish outside the fake test clock.
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Foto seleccionada'), findsOneWidget);
      expect(tester.state(find.byType(EditProfileScreen)), same(formState));
      await tester.ensureVisible(find.text('Guardar y continuar'));
      await tester.tap(find.text('Guardar y continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Área privada'), findsOneWidget);
      expect(service.perfiles['A']!.username, 'Knight_photo');
      expect(service.perfiles['A']!.genero, 'prefiero_no_decir');
      expect(service.perfiles['A']!.completo, isTrue);
      expect(service.perfiles['A']!.avatarPath, 'A/new.png');
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  testWidgets('Failed resume verification and retry preserve setup draft', (
    tester,
  ) async {
    final service = FakePerfilService();
    final auth = GoTrueClient();
    await tester.pumpWidget(
      harness(
        ProfileGate(
          userId: 'A',
          service: service,
          child: const Text('Área privada'),
        ),
        auth,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Keep_my_draft');
    final formState = tester.state(find.byType(EditProfileScreen));
    service.fallaCarga = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Área privada'), findsNothing);
    expect(tester.state(find.byType(EditProfileScreen)), same(formState));
    service.fallaCarga = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      'Keep_my_draft',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
  });

  test('Avatar validates type/size and preserves optional profile field', () {
    final png = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
    expect(PerfilService.tipoFoto(png).mime, 'image/png');
    expect(
      () => PerfilService.tipoFoto(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
    expect(
      () => PerfilService.tipoFoto(Uint8List(PerfilService.maxFotoBytes + 1)),
      throwsFormatException,
    );
    final json = completo('A').toJson()..['avatar_path'] = 'A/photo.png';
    expect(Perfil.fromJson(json).avatarPath, 'A/photo.png');
    expect(Perfil.fromJson(json).completo, isTrue);
  });

  test('Avatar replacement cleans old file on success and new file on save failure', () async {
    final service = FakeAvatarService();
    final old = Perfil(
      id: 'A',
      username: 'Knight',
      fechaNacimiento: DateTime(2000),
      genero: 'otro',
      avatarPath: 'A/old.png',
    );
    final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
    service.perfiles['A'] = old;
    service.duplicado = true;
    await expectLater(
      service.guardarConFoto(old, bytes),
      throwsA(isA<PostgrestException>()),
    );
    expect(service.borrados, ['A/new.png']);
    expect(service.perfiles['A']!.avatarPath, 'A/old.png');
    service.borrados.clear();
    service.duplicado = false;
    final saved = await service.guardarConFoto(old, bytes);
    expect(saved.avatarPath, 'A/new.png');
    expect(service.borrados, ['A/old.png']);
  });

  test(
    'Missing photo does not block complete profile; data edit keeps path',
    () async {
      final service = FakeAvatarService()..fallaFoto = true;
      service.perfiles['A'] = Perfil(
        id: 'A',
        username: 'Knight',
        fechaNacimiento: DateTime(2000),
        genero: 'otro',
        avatarPath: 'A/old.png',
      );
      final provider = PerfilProvider(userId: 'A', service: service);
      await provider.cargar();
      await Future<void>.delayed(Duration.zero);
      expect(provider.errorCarga, isNull);
      expect(provider.perfil!.completo, isTrue);
      expect(provider.errorFoto, isNotNull);
      expect(
        await provider.guardar('Knight_2', DateTime(2000), 'otro'),
        isNull,
      );
      expect(service.perfiles['A']!.avatarPath, 'A/old.png');
      provider.dispose();
    },
  );

  test('Profile completeness and validation use all fields, no local flag', () {
    expect(completo('A').completo, isTrue);
    expect(
      Perfil.fromJson({'id': 'A', 'username': 'Jugador_1'}).completo,
      isFalse,
    );
    expect(Perfil.validarUsername('a'), isNotNull);
    expect(Perfil.validarUsername('name with spaces'), isNotNull);
    expect(Perfil.validarUsername('  Knight_42  '), isNull);
    expect(Perfil.fechaValida(DateTime(1899)), isFalse);
    expect(
      Perfil.fechaValida(DateTime.now().add(const Duration(days: 1))),
      isFalse,
    );
    expect(Perfil.fromJson(completo('A').toJson()).completo, isTrue);
  });

  test(
    'Save only accepts server result; duplicate preserves old profile',
    () async {
      final service = FakePerfilService()..perfiles['A'] = completo('A');
      final provider = PerfilProvider(userId: 'A', service: service);
      await provider.cargar();
      service.duplicado = true;
      expect(
        await provider.guardar('Taken', DateTime(2000), 'hombre'),
        'Ese nombre de usuario ya está ocupado.',
      );
      expect(provider.perfil!.username, 'Jugador_1');
      expect(provider.guardando, isFalse);
      service.duplicado = false;
      expect(
        await provider.guardar('New_name', DateTime(2000), 'otro'),
        isNull,
      );
      expect(provider.perfil!.username, 'New_name');
      provider.dispose();
    },
  );

  test('Late load cannot update a disposed account provider', () async {
    final pending = Completer<Perfil?>();
    final service = FakePerfilService()..pendiente = pending;
    final provider = PerfilProvider(userId: 'A', service: service);
    final request = provider.cargar();
    provider.dispose();
    pending.complete(completo('A'));
    await request;
    expect(provider.perfil, isNull);
  });

  testWidgets(
    'Setup survives closing; completed row unlocks on reopening; other account stays gated',
    (tester) async {
      final service = FakePerfilService();
      final auth = GoTrueClient();
      Future<void> open(String id, int instance) async {
        await tester.pumpWidget(
          harness(
            ProfileGate(
              key: ValueKey(instance),
              userId: id,
              service: service,
              child: const Text('Área privada'),
            ),
            auth,
          ),
        );
        await tester.pumpAndSettle();
      }

      await open('A', 1);
      expect(find.text('Completa tu perfil'), findsOneWidget);
      expect(find.text('Área privada'), findsNothing);
      await open('A', 2);
      expect(find.text('Completa tu perfil'), findsOneWidget);
      service.perfiles['A'] = completo('A');
      await open('A', 3);
      expect(find.text('Área privada'), findsOneWidget);
      await open('B', 4);
      expect(find.text('Completa tu perfil'), findsOneWidget);
      expect(find.text('Área privada'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  testWidgets(
    'Failed verification blocks app and retries; resume detects missing profile',
    (tester) async {
      final service = FakePerfilService()..fallaCarga = true;
      final auth = GoTrueClient();
      await tester.pumpWidget(
        harness(
          ProfileGate(
            userId: 'A',
            service: service,
            child: const Text('Área privada'),
          ),
          auth,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Área privada'), findsNothing);
      service.fallaCarga = false;
      service.perfiles['A'] = completo('A');
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Área privada'), findsOneWidget);
      service.perfiles.remove('A');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Completa tu perfil'), findsOneWidget);
      expect(find.text('Área privada'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  testWidgets(
    'Setup validates and saves all required fields before unlocking',
    (tester) async {
      final service = FakePerfilService();
      final auth = GoTrueClient();
      await tester.pumpWidget(
        harness(
          ProfileGate(
            userId: 'A',
            service: service,
            child: const Text('Área privada'),
          ),
          auth,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar y continuar'));
      await tester.tap(find.text('Guardar y continuar'));
      await tester.pumpAndSettle();
      expect(service.perfiles, isEmpty);
      expect(find.text('Selecciona una fecha válida.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'My_Knight');
      await tester.ensureVisible(find.text('Selecciona una fecha'));
      await tester.tap(find.text('Selecciona una fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prefiero no decirlo').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar y continuar'));
      await tester.tap(find.text('Guardar y continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Área privada'), findsOneWidget);
      expect(service.perfiles['A']!.username, 'My_Knight');
      expect(service.perfiles['A']!.completo, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );

  testWidgets('Bottom navigation opens editable profile and returns to menu', (
    tester,
  ) async {
    final service = FakePerfilService()..perfiles['A'] = completo('A');
    final provider = PerfilProvider(userId: 'A', service: service);
    final auth = GoTrueClient();
    await provider.cargar();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: harness(const MainScreen(), auth),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo quieres jugar?'), findsOneWidget);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Tu perfil'), findsOneWidget);
    expect(find.text('Jugador_1'), findsNWidgets(2));
    expect(find.byType(TextFormField), findsNothing);
    await tester.tap(find.byTooltip('Editar perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Cambiar foto'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Unsaved_name');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Unsaved_name'), findsNothing);
    expect(service.perfiles['A']!.username, 'Jugador_1');
    await tester.tap(find.byTooltip('Editar perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Saved_name');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Saved_name'), findsNWidgets(2));
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo quieres jugar?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
    auth.dispose();
  });
}
