import 'package:firebase_portfolio/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthScreen', () {
    testWidgets('muestra el formulario de inicio de sesión', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      expect(find.text('Firebase Portfolio'), findsOneWidget);
      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('permite cambiar al formulario de registro', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
      await tester.pump();

      expect(find.text('Crea una cuenta'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);
    });

    testWidgets('vuelve del registro al inicio de sesión', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
      await tester.pump();

      await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
      await tester.pump();

      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('valida que correo y contraseña no estén vacíos', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Introduce tu correo y contraseña.'), findsOneWidget);
    });
  });
}
