import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medical_diagnosis_ai/presentation/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: const OutlineInputBorder(),
                errorText: emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: const OutlineInputBorder(),
                errorText: passwordError,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  emailError = emailController.text.isEmpty
                      ? 'El correo no puede estar vacío'
                      : null;
                  passwordError = passwordController.text.isEmpty
                      ? 'La contraseña no puede estar vacía'
                      : null;
                });

                if (emailError == null && passwordError == null) {
                  await widget.authController.login(
                    emailController.text,
                    passwordController.text,
                  );
                }
              },
              child: const Text('Iniciar Sesión'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
