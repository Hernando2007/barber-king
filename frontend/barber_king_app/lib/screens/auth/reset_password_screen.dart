import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final correoController =
      TextEditingController();

  final codigoController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmarController =
      TextEditingController();

  final AuthService authService =
      AuthService();

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
    final correo =
        correoController.text.trim();

    final codigo =
        codigoController.text.trim();

    final password =
        passwordController.text.trim();

    final confirmar =
        confirmarController.text.trim();

    if (correo.isEmpty ||
        codigo.isEmpty ||
        password.isEmpty ||
        confirmar.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Complete todos los campos.",
          ),
        ),
      );
      return;
    }

    if (codigo.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "El código OTP debe tener 6 dígitos.",
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "La contraseña debe tener mínimo 6 caracteres.",
          ),
        ),
      );
      return;
    }

    if (password != confirmar) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Las contraseñas no coinciden.",
          ),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta =
        await authService
            .restablecerPassword(
      correo: correo,
      codigo: codigo,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          respuesta["message"] ??
              "Solicitud procesada.",
        ),
      ),
    );

    if (respuesta["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Restablecer contraseña",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),

            const Icon(
              Icons.lock_reset,
              size: 80,
              color:
                  AppColors.primary,
            ),

            const SizedBox(
              height: 25,
            ),

            TextField(
              controller:
                  correoController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Correo",
                prefixIcon:
                    Icon(
                  Icons.email,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller:
                  codigoController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Código OTP",
                prefixIcon:
                    Icon(
                  Icons.pin,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller:
                  passwordController,
              obscureText:
                  ocultarPassword,
              decoration:
                  InputDecoration(
                labelText:
                    "Nueva contraseña",
                prefixIcon:
                    const Icon(
                  Icons.lock,
                ),
                suffixIcon:
                    IconButton(
                  icon: Icon(
                    ocultarPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarPassword =
                          !ocultarPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller:
                  confirmarController,
              obscureText:
                  ocultarConfirmar,
              decoration:
                  InputDecoration(
                labelText:
                    "Confirmar contraseña",
                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon:
                    IconButton(
                  icon: Icon(
                    ocultarConfirmar
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarConfirmar =
                          !ocultarConfirmar;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton(
                onPressed:
                    cargando
                        ? null
                        : cambiarPassword,
                child:
                    cargando
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Cambiar contraseña",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}