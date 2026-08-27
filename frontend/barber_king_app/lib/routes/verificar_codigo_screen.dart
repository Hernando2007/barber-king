import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';

class VerificarCodigoScreen extends StatefulWidget {
  final String correo;

  const VerificarCodigoScreen({super.key, required this.correo});

  @override
  State<VerificarCodigoScreen> createState() => _VerificarCodigoScreenState();
}

class _VerificarCodigoScreenState extends State<VerificarCodigoScreen> {
  final AuthService authService = AuthService();

  final codigoController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmarController = TextEditingController();

  bool cargando = false;

  bool ocultarPassword = true;

  bool ocultarConfirmar = true;

  @override
  void dispose() {
    codigoController.dispose();

    passwordController.dispose();

    confirmarController.dispose();

    super.dispose();
  }

  Future<void> cambiarPassword() async {
    final codigo = codigoController.text.trim();

    final password = passwordController.text.trim();

    final confirmar = confirmarController.text.trim();

    if (codigo.isEmpty || password.isEmpty || confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos.")),
      );

      return;
    }

    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El código debe tener 6 dígitos.")),
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
      correo: widget.correo,
      codigo: codigo,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (respuesta["success"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(respuesta["message"])));

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(respuesta["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Verificar código")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.mark_email_read,
                size: 90,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                widget.correo,
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Código OTP",
                  prefixIcon: Icon(Icons.pin),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  prefixIcon: const Icon(Icons.lock),
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

              const SizedBox(height: 20),

              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
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
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : cambiarPassword,
                  child: cargando
                      ? const CircularProgressIndicator()
                      : const Text("Cambiar contraseña"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
