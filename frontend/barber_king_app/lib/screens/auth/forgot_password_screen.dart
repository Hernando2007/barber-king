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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 40),

              Container(
                width: 120,
                height: 120,

                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),

                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "¿Olvidaste tu contraseña?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Ingresa tu correo electrónico y te enviaremos un código OTP para restablecer tu contraseña.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),

                child: Column(
                  children: [
                    TextField(
                      controller: correoController,

                      keyboardType: TextInputType.emailAddress,

                      style: const TextStyle(color: AppColors.white),

                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",

                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed: cargando ? null : enviar,

                        child: cargando
                            ? const CircularProgressIndicator()
                            : const Text(
                                "ENVIAR CÓDIGO",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "El código OTP tendrá una validez de 15 minutos.",
                        style: TextStyle(color: AppColors.subtitle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
