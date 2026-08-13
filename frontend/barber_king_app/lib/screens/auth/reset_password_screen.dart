import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/colors.dart';

class ResetPasswordScreen extends StatefulWidget {

  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmarController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool cargando = false;

  bool ocultarPassword = true;

  bool ocultarConfirmar = true;

  @override
  void dispose() {

    passwordController.dispose();

    confirmarController.dispose();

    super.dispose();
  }
  // CAMBIAR CONTRASEÑA
  Future<void> cambiarPassword() async {

    final password =
        passwordController.text.trim();

    final confirmar =
        confirmarController.text.trim();

    if (password.isEmpty ||
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
        await authService.cambiarPassword(
      token: widget.token,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (respuesta["success"] == true) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            respuesta["message"] ??
                "Contraseña actualizada correctamente.",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            respuesta["message"] ??
                "No se pudo cambiar la contraseña.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Nueva contraseña",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.lock_reset,
              size: 80,
              color:
                  AppColors.primary,
            ),

            const SizedBox(
              height: 25,
            ),

            const Text(
              "Crear nueva contraseña",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.white,
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(

              controller:
                  passwordController,

              obscureText:
                  ocultarPassword,

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  InputDecoration(

                labelText:
                    "Nueva contraseña",

                labelStyle:
                    const TextStyle(
                  color:
                      Colors.white70,
                ),

                prefixIcon:
                    const Icon(
                  Icons.lock,
                  color:
                      AppColors.primary,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(
                    ocultarPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color:
                        Colors.white70,
                  ),

                  onPressed: () {

                    setState(() {
                      ocultarPassword =
                          !ocultarPassword;
                    });

                  },
                ),

                filled: true,

                fillColor:
                    AppColors.surface,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
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

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  InputDecoration(

                labelText:
                    "Confirmar contraseña",

                labelStyle:
                    const TextStyle(
                  color:
                      Colors.white70,
                ),

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                  color:
                      AppColors.primary,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(
                    ocultarConfirmar
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color:
                        Colors.white70,
                  ),

                  onPressed: () {

                    setState(() {
                      ocultarConfirmar =
                          !ocultarConfirmar;
                    });

                  },
                ),

                filled: true,

                fillColor:
                    AppColors.surface,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
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

                child: cargando

                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(),
                      )

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