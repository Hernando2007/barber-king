import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final correoController = TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;

  @override
  void dispose() {
    correoController.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    final correo = correoController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese su correo electrónico.")),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta = await authService.recuperarPassword(correo);

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta["message"] ?? "Solicitud procesada.")),
    );

    if (respuesta["success"] == true) {
      correoController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Recuperar contraseña")),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),

            const SizedBox(height: 25),

            const Text(
              "Recuperar contraseña",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Ingresa tu correo electrónico y recibirás un código OTP de 6 dígitos para restablecer tu contraseña.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: cargando ? null : enviar,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text("Enviar código"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
