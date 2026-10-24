import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/account_type_selector.dart';
import '../../widgets/auth/barber_registration_fields.dart';
import '../../widgets/common/app_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _picker = ImagePicker();

  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _fecha = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  final _especialidad = TextEditingController();
  final _experiencia = TextEditingController();
  final _descripcion = TextEditingController();

  int _rol = 3;
  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  XFile? _diploma;

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _correo,
      _telefono,
      _fecha,
      _password,
      _confirmar,
      _especialidad,
      _experiencia,
      _descripcion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (value == null) return;

    _fecha.text =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    setState(() => _diploma = file);
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_password.text != _confirmar.text) {
      showAppSnack(context, 'Las contraseñas no coinciden.', error: true);
      return;
    }

    setState(() => _cargando = true);

    Uint8List? diplomaBytes;
    if (_rol == 2 && _diploma != null) {
      diplomaBytes = await _diploma!.readAsBytes();
    }

    final respuesta = await _auth.registrar(
      rolId: _rol,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      telefono: _telefono.text,
      fechaNacimiento: _fecha.text,
      password: _password.text,
      especialidad: _rol == 2 ? _especialidad.text : null,
      experiencia:
          _rol == 2 ? int.tryParse(_experiencia.text.trim()) : null,
      descripcion: _rol == 2 ? _descripcion.text : null,
      diplomaBytes: diplomaBytes,
      diplomaNombre: _diploma?.name,
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (respuesta['success'] == true) {
      showAppSnack(
        context,
        'Cuenta creada correctamente. Ya puedes iniciar sesión.',
      );
      Navigator.pop(context);
    } else {
      showAppSnack(
        context,
        respuesta['message'] ?? 'No se pudo crear la cuenta.',
        error: true,
      );
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
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
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.content_cut_rounded,
                    color: AppColors.primary,
                    size: 46,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ÚNETE A BARBER KING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Crea tu cuenta y vive la experiencia premium.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Tipo de cuenta',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AccountTypeSelector(
                            value: _rol,
                            onChanged: (value) {
                              setState(() {
                                _rol = value;
                                if (_rol != 2) {
                                  _diploma = null;
                                  _especialidad.clear();
                                  _experiencia.clear();
                                  _descripcion.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          const SectionHeader(
                            title: 'Datos personales',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombres,
                            textCapitalization: TextCapitalization.words,
                            decoration: _decoration(
                              'Nombres',
                              Icons.person_outline_rounded,
                            ),
                            validator: _requerido,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _apellidos,
                            textCapitalization: TextCapitalization.words,
                            decoration: _decoration(
                              'Apellidos',
                              Icons.badge_outlined,
                            ),
                            validator: _requerido,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _correo,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _decoration(
                              'Correo electrónico',
                              Icons.email_outlined,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) return 'Ingresa tu correo.';
                              if (!text.contains('@') || !text.contains('.')) {
                                return 'Ingresa un correo válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _telefono,
                            keyboardType: TextInputType.phone,
                            decoration: _decoration(
                              'Teléfono',
                              Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _fecha,
                            readOnly: true,
                            onTap: _seleccionarFecha,
                            decoration: _decoration(
                              'Fecha de nacimiento',
                              Icons.calendar_month_outlined,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SectionHeader(
                            title: 'Seguridad',
                            icon: Icons.lock_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: _ocultarPassword,
                            decoration: _decoration(
                              'Contraseña',
                              Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _ocultarPassword = !_ocultarPassword,
                                ),
                                icon: Icon(
                                  _ocultarPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Mínimo 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmar,
                            obscureText: _ocultarConfirmar,
                            decoration: _decoration(
                              'Confirmar contraseña',
                              Icons.lock_reset_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _ocultarConfirmar = !_ocultarConfirmar,
                                ),
                                icon: Icon(
                                  _ocultarConfirmar
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: _requerido,
                          ),
                          if (_rol == 2) ...[
                            const SizedBox(height: 24),
                            BarberRegistrationFields(
                              specialtyController: _especialidad,
                              experienceController: _experiencia,
                              descriptionController: _descripcion,
                              diplomaName: _diploma?.name,
                              onPickDiploma: _seleccionarDiploma,
                              onRemoveDiploma: () =>
                                  setState(() => _diploma = null),
                            ),
                          ],
                          const SizedBox(height: 26),
                          PrimaryGradientButton(
                            label: _rol == 2
                                ? 'REGISTRARME COMO BARBERO'
                                : 'CREAR CUENTA',
                            icon: Icons.person_add_alt_1_rounded,
                            loading: _cargando,
                            onPressed: _cargando ? null : _registrar,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                _cargando ? null : () => Navigator.pop(context),
                            child: const Text('Ya tengo una cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }
}
