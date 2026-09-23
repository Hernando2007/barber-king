import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombres = TextEditingController();
  final apellidos = TextEditingController();
  final correo = TextEditingController();
  final telefono = TextEditingController();
  final fecha = TextEditingController();
  final password = TextEditingController();
  final confirmar = TextEditingController();

  final auth = AuthService();

  bool cargando = false;
  bool ocultarPassword = true;
  bool ocultarConfirmar = true;
  int rol = 3;

  @override
  void dispose() {
    for (final c in [
      nombres,
      apellidos,
      correo,
      telefono,
      fecha,
      password,
      confirmar,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> seleccionarFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (f != null) {
      fecha.text =
          "${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> registrar() async {
    final campos = [nombres, apellidos, correo, password, confirmar];

    if (campos.any((c) => c.text.trim().isEmpty)) {
      mensaje("Complete todos los campos obligatorios.");
      return;
    }

    if (password.text != confirmar.text) {
      mensaje("Las contraseñas no coinciden.");
      return;
    }

    setState(() => cargando = true);

    final respuesta = await auth.registrar(
      rolId: rol,
      nombres: nombres.text.trim(),
      apellidos: apellidos.text.trim(),
      correo: correo.text.trim(),
      telefono: telefono.text.trim(),
      fechaNacimiento: fecha.text.trim(),
      password: password.text.trim(),
    );

    if (!mounted) return;

    setState(() => cargando = false);

    if (respuesta["success"] == true) {
      mensaje("Usuario registrado correctamente.");
      Navigator.pop(context);
    } else {
      mensaje(respuesta["message"] ?? "Error al registrar.");
    }
  }

  Widget campo(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? tipo,
    bool lectura = false,
    VoidCallback? tocar,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      readOnly: lectura,
      onTap: tocar,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget campoPassword(
    String label,
    IconData icon,
    TextEditingController controller,
    bool ocultar,
    VoidCallback cambiar,
  ) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          onPressed: cambiar,
          icon: Icon(
            ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                      color: AppColors.primary.withValues(alpha: .08),
                      blurRadius: 20,
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
                      initialValue: rol,
                      dropdownColor: AppColors.surface,
                      decoration: const InputDecoration(
                        labelText: "Tipo de cuenta",
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text("Cliente")),
                        DropdownMenuItem(value: 2, child: Text("Barbero")),
                      ],
                      onChanged: (v) => setState(() => rol = v ?? 3),
                    ),

                    const SizedBox(height: 18),

                    campo("Nombres", Icons.person_outline, nombres),
                    const SizedBox(height: 18),

                    campo("Apellidos", Icons.person_outline, apellidos),
                    const SizedBox(height: 18),

                    campo(
                      "Correo electrónico",
                      Icons.email_outlined,
                      correo,
                      tipo: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    campo(
                      "Teléfono",
                      Icons.phone_outlined,
                      telefono,
                      tipo: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    campo(
                      "Fecha de nacimiento",
                      Icons.calendar_month_outlined,
                      fecha,
                      lectura: true,
                      tocar: seleccionarFecha,
                    ),
                    const SizedBox(height: 18),

                    campoPassword(
                      "Contraseña",
                      Icons.lock_outline,
                      password,
                      ocultarPassword,
                      () => setState(() => ocultarPassword = !ocultarPassword),
                    ),
                    const SizedBox(height: 18),

                    campoPassword(
                      "Confirmar contraseña",
                      Icons.lock_reset_outlined,
                      confirmar,
                      ocultarConfirmar,
                      () =>
                          setState(() => ocultarConfirmar = !ocultarConfirmar),
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
                      onPressed: () => Navigator.pop(context),
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
