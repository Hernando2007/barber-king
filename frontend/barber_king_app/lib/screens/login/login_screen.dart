import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../auth/forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final correoController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  Future<void> iniciarSesion() async {

    final correo =
        correoController.text.trim();

    final password =
        passwordController.text.trim();

    if (
        correo.isEmpty ||
        password.isEmpty
    ) {

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

    setState(() {
      cargando = true;
    });

    final respuesta =
        await authService.login(
      correo: correo,
      contrasena: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (respuesta["success"] == true) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          respuesta["message"] ??
              "Error al iniciar sesión.",
        ),
      ),
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(
            25,
          ),

          child: Column(

            children: [

              const SizedBox(
                height: 40,
              ),

              const Icon(
                Icons.content_cut,
                color:
                    AppColors.primary,
                size: 90,
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                "BARBER KING",
                style: TextStyle(
                  fontSize: 30,
                  color:
                      AppColors.white,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Bienvenido nuevamente",
                style: TextStyle(
                  color:
                      Colors.white70,
                ),
              ),

              const SizedBox(
                height: 45,
              ),

              TextField(
                controller:
                    correoController,
                keyboardType:
                    TextInputType
                        .emailAddress,
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
                height: 20,
              ),

              TextField(
                controller:
                    passwordController,
                obscureText:
                    ocultarPassword,
                decoration:
                    InputDecoration(
                  labelText:
                      "Contraseña",
                  prefixIcon:
                      const Icon(
                    Icons.lock,
                  ),
                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      ocultarPassword
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
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
                height: 35,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                  onPressed:
                      cargando
                          ? null
                          : iniciarSesion,
                  child:
                      cargando
                          ? const CircularProgressIndicator()
                          : const Text(
                              "INICIAR SESIÓN",
                            ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ForgotPasswordScreen(),
                    ),
                  );

                },
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}