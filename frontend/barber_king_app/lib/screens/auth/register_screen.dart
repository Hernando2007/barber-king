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

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      fechaController.text =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
    }
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

  Widget campoSeparador() {
    return const SizedBox(height: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      size: 90,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "CREAR CUENTA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Únete a la experiencia premium de Barber King",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtitle),
                    ),

                    const SizedBox(height: 30),

                    DropdownButtonFormField<int>(
                      value: rolSeleccionado,
                      dropdownColor: AppColors.surface,
                      decoration: const InputDecoration(
                        labelText: "Tipo de cuenta",
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
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

                    campoSeparador(),

                    TextField(
                      controller: nombresController,
                      decoration: const InputDecoration(
                        labelText: "Nombres",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: apellidosController,
                      decoration: const InputDecoration(
                        labelText: "Apellidos",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Teléfono",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: fechaController,
                      readOnly: true,
                      onTap: seleccionarFecha,
                      decoration: const InputDecoration(
                        labelText: "Fecha de nacimiento",
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: passwordController,
                      obscureText: ocultarPassword,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline),
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
                          ),
                        ),
                      ),
                    ),

                    campoSeparador(),

                    TextField(
                      controller: confirmarController,
                      obscureText: ocultarConfirmacion,
                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarConfirmacion = !ocultarConfirmacion;
                            });
                          },
                          icon: Icon(
                            ocultarConfirmacion
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: cargando ? null : registrar,
                        child: cargando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text("CREAR CUENTA"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ya tengo una cuenta"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
