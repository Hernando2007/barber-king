import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombresController = TextEditingController();

  final apellidosController = TextEditingController();

  final correoController = TextEditingController();

  final telefonoController = TextEditingController();

  final fechaController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmarController = TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;

  bool ocultarPassword = true;

  bool ocultarConfirmacion = true;

  int rolSeleccionado = 3;

  Future<void> registrar() async {
    if (nombresController.text.isEmpty ||
        apellidosController.text.isEmpty ||
        correoController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete todos los campos obligatorios."),
        ),
      );

      return;
    }

    if (passwordController.text != confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden.")),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta = await authService.registrar(
      rolId: rolSeleccionado,
      nombres: nombresController.text.trim(),
      apellidos: apellidosController.text.trim(),
      correo: correoController.text.trim(),
      telefono: telefonoController.text.trim(),
      fechaNacimiento: fechaController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (respuesta["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado correctamente.")),
      );

      Navigator.pop(context);

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta["message"] ?? "Error al registrar.")),
    );
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    fechaController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Crear cuenta")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.person_add, color: AppColors.primary, size: 80),

            const SizedBox(height: 30),

            DropdownButtonFormField<int>(
              initialValue: rolSeleccionado,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: "Tipo de cuenta"),
              items: const [
                DropdownMenuItem(value: 3, child: Text("Cliente")),
                DropdownMenuItem(value: 2, child: Text("Barbero")),
              ],
              onChanged: (value) {
                setState(() {
                  rolSeleccionado = value ?? 3;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nombresController,
              decoration: const InputDecoration(labelText: "Nombres"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: apellidosController,
              decoration: const InputDecoration(labelText: "Apellidos"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Correo"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: "Fecha nacimiento (YYYY-MM-DD)",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: ocultarPassword,
              decoration: InputDecoration(
                labelText: "Contraseña",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      ocultarPassword = !ocultarPassword;
                    });
                  },
                  icon: Icon(
                    ocultarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmarController,
              obscureText: ocultarConfirmacion,
              decoration: InputDecoration(
                labelText: "Confirmar contraseña",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      ocultarConfirmacion = !ocultarConfirmacion;
                    });
                  },
                  icon: Icon(
                    ocultarConfirmacion
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: cargando ? null : registrar,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text("REGISTRARSE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
