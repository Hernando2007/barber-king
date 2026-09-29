import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/account_type_selector.dart';
import '../../widgets/auth/barber_registration_fields.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _picker = ImagePicker();

  final nombres = TextEditingController();
  final apellidos = TextEditingController();
  final correo = TextEditingController();
  final telefono = TextEditingController();
  final fecha = TextEditingController();
  final password = TextEditingController();
  final confirmar = TextEditingController();
  final especialidad = TextEditingController();

  int rol = 3;
  bool cargando = false;
  bool ocultarPassword = true;
  bool ocultarConfirmar = true;
  XFile? diploma;

  @override
  void dispose() {
    for (final controller in [
      nombres,
      apellidos,
      correo,
      telefono,
      fecha,
      password,
      confirmar,
      especialidad,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (value == null) return;

    fecha.text =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> seleccionarDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;

    setState(() => diploma = file);
  }

  Future<void> registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (rol == 2 && especialidad.text.trim().isEmpty) {
      _mensaje('La especialidad es obligatoria para el barbero.');
      return;
    }

    if (password.text != confirmar.text) {
      _mensaje('Las contraseñas no coinciden.');
      return;
    }

    setState(() => cargando = true);

    final respuesta = await _auth.registrar(
      rolId: rol,
      nombres: nombres.text,
      apellidos: apellidos.text,
      correo: correo.text,
      telefono: telefono.text,
      fechaNacimiento: fecha.text,
      password: password.text,
      especialidad:
          rol == 2 ? especialidad.text : null,
      diplomaPath: rol == 2 ? diploma?.path : null,
    );

    if (!mounted) return;

    setState(() => cargando = false);

    if (respuesta['success'] == true) {
      _mensaje('Cuenta creada correctamente.');
      Navigator.pop(context);
    } else {
      _mensaje(
        respuesta['message'] ?? 'No se pudo crear la cuenta.',
      );
    }
  }

  void _mensaje(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _decoracion(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.content_cut,
                          color: AppColors.primary,
                          size: 64,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'BARBER KING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crea tu cuenta y personaliza tu experiencia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.subtitle),
                        ),
                        const SizedBox(height: 25),
                        AccountTypeSelector(
                          value: rol,
                          onChanged: (value) {
                            setState(() {
                              rol = value;
                              if (rol != 2) diploma = null;
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: nombres,
                          decoration: _decoracion(
                            'Nombres',
                            Icons.person_outline,
                          ),
                          validator: _requerido,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: apellidos,
                          decoration: _decoracion(
                            'Apellidos',
                            Icons.badge_outlined,
                          ),
                          validator: _requerido,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: correo,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _decoracion(
                            'Correo electrónico',
                            Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese su correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: telefono,
                          keyboardType: TextInputType.phone,
                          decoration: _decoracion(
                            'Teléfono',
                            Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: fecha,
                          readOnly: true,
                          onTap: seleccionarFecha,
                          decoration: _decoracion(
                            'Fecha de nacimiento',
                            Icons.calendar_month_outlined,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: password,
                          obscureText: ocultarPassword,
                          decoration: _decoracion(
                            'Contraseña',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => ocultarPassword =
                                    !ocultarPassword,
                              ),
                              icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: confirmar,
                          obscureText: ocultarConfirmar,
                          decoration: _decoracion(
                            'Confirmar contraseña',
                            Icons.lock_reset_outlined,
                          ).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => ocultarConfirmar =
                                    !ocultarConfirmar,
                              ),
                              icon: Icon(
                                ocultarConfirmar
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: _requerido,
                        ),
                        if (rol == 2) ...[
                          const SizedBox(height: 25),
                          BarberRegistrationFields(
                            specialtyController: especialidad,
                            diplomaName: diploma?.name,
                            onPickDiploma: seleccionarDiploma,
                            onRemoveDiploma: () =>
                                setState(() => diploma = null),
                          ),
                        ],
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: cargando ? null : registrar,
                            child: cargando
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    rol == 2
                                        ? 'REGISTRARME COMO BARBERO'
                                        : 'CREAR CUENTA',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Ya tengo una cuenta'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }
}
