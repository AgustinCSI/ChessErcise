import 'package:chess_ercise/app.dart';
import 'package:chess_ercise/presentation/providers/auth_provider.dart';
import 'package:chess_ercise/presentation/screens/auth/login_screen.dart';
import 'package:chess_ercise/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth extends GoTrueClient {
  String? correo;
  String? redirect;
  int solicitudes = 0;
  bool falla = false;

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    solicitudes++;
    correo = email;
    if (falla) throw const AuthException('Credenciales incorrectas');
    return AuthResponse();
  }

  @override
  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    OtpChannel channel = OtpChannel.sms,
  }) async {
    redirect = emailRedirectTo;
    return AuthResponse();
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    throw const AuthException('No se pudo cerrar sesión');
  }
}

void main() {
  testWidgets('Missing configuration shows instructions', (tester) async {
    await tester.pumpWidget(const ChessErciseApp(supabaseDisponible: false));
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
  });

  test(
    'Provider restores loading and distinguishes confirmation from error',
    () async {
      final client = FakeAuth();
      final auth = AuthProvider(auth: client);
      expect(await auth.registrar('a@b.cl', '123456'), isNull);
      expect(auth.requiereConfirmacion, isTrue);
    expect(client.redirect, 'chessercise://login-callback/');
      client.falla = true;
      expect(
        await auth.ingresar(' a@b.cl ', '123456'),
        'Credenciales incorrectas',
      );
      expect(client.correo, 'a@b.cl');
      expect(auth.cargando, isFalse);
      expect(auth.requiereConfirmacion, isFalse);
      expect(await auth.salir(), 'No se pudo cerrar sesión');
      expect(auth.cargando, isFalse);
      auth.dispose();
      client.dispose();
    },
  );

  testWidgets(
    'Invalid form never submits; registration checks matching passwords',
    (tester) async {
      final client = FakeAuth();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(auth: client),
          child: MaterialApp(theme: AppTheme.claro, home: const LoginScreen()),
        ),
      );
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      expect(find.text('Ingresa un correo válido.'), findsOneWidget);
      expect(client.solicitudes, 0);
      await tester.tap(find.text('Crear una cuenta'));
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.enterText(find.byType(TextFormField).at(2), '654321');
      await tester.ensureVisible(find.text('Crear cuenta'));
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      client.dispose();
    },
  );
}
