import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final correoController = TextEditingController();

  final codigoController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmarController = TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;

  bool ocultarPassword = true;

  bool ocultarConfirmar = true;

  @override
  void dispose() {
    correoController.dispose();
    codigoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  Future<void> cambiarPassword() async {
    final correo = correoController.text.trim();

    final codigo = codigoController.text.trim();

    final password = passwordController.text.trim();

    final confirmar = confirmarController.text.trim();

    if (correo.isEmpty ||
        codigo.isEmpty ||
        password.isEmpty ||
        confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos.")),
      );
      return;
    }

    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El código OTP debe tener 6 dígitos.")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener mínimo 6 caracteres."),
        ),
      );
      return;
    }

    if (password != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden.")),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta = await authService.restablecerPassword(
      correo: correo,
      codigo: codigo,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta["message"] ?? "Solicitud procesada.")),
    );

    if (respuesta["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Restablecer contraseña")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 30),

              Container(
                width: 120,
                height: 120,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),

                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                  size: 60,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Nueva contraseña",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Ingresa el código OTP recibido y define una nueva contraseña segura.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

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

                    const SizedBox(height: 20),

                    TextField(
                      controller: codigoController,

                      keyboardType: TextInputType.number,

                      style: const TextStyle(color: AppColors.white),

                      decoration: const InputDecoration(
                        labelText: "Código OTP",

                        prefixIcon: Icon(
                          Icons.pin_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: passwordController,

                      obscureText: ocultarPassword,

                      style: const TextStyle(color: AppColors.white),

                      decoration: InputDecoration(
                        labelText: "Nueva contraseña",

                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: confirmarController,

                      obscureText: ocultarConfirmar,

                      style: const TextStyle(color: AppColors.white),

                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",

                        prefixIcon: const Icon(
                          Icons.lock_reset,
                          color: AppColors.primary,
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarConfirmar = !ocultarConfirmar;
                            });
                          },
                          icon: Icon(
                            ocultarConfirmar
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed: cargando ? null : cambiarPassword,

                        child: cargando
                            ? const CircularProgressIndicator()
                            : const Text(
                                "ACTUALIZAR CONTRASEÑA",
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
                    Icon(Icons.security, color: AppColors.primary),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Utiliza una contraseña fuerte con letras, números y símbolos.",
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
