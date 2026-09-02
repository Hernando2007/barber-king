import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();

  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;

  bool ocultarPassword = true;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final correo = correoController.text.trim();

    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos.")),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta = await authService.login(
      correo: correo,
      contrasena: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta["message"] ?? "Proceso completado")),
    );

    if (respuesta["success"] == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.content_cut,
                  size: 90,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 20),

                const Text(
                  "BARBER KING",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(color: AppColors.subtitle),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: correoController,

                  keyboardType: TextInputType.emailAddress,

                  style: const TextStyle(color: Colors.white, fontSize: 16),

                  cursorColor: AppColors.primary,

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
                  controller: passwordController,

                  obscureText: ocultarPassword,

                  style: const TextStyle(color: Colors.white, fontSize: 16),

                  cursorColor: AppColors.primary,

                  decoration: InputDecoration(
                    labelText: "Contraseña",

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
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,

                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },

                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed: cargando ? null : login,

                    child: cargando
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Iniciar Sesión"),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text(
                      "¿No tienes cuenta?",
                      style: TextStyle(color: AppColors.subtitle),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },

                      child: const Text("Registrarse"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
