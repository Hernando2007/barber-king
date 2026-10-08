import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/registro_service.dart';
import '../../widgets/common/app_field.dart';
import 'barber_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _fecha = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  final _servicio = RegistroService();

  int _rol = 3; // 3 = Cliente, 2 = Barbero
  DateTime? _nacimiento;
  bool _cargando = false;

  @override
  void dispose() {
    for (final c in [
      _nombres,
      _apellidos,
      _correo,
      _telefono,
      _fecha,
      _password,
      _confirmar,
    ])
      c.dispose();
    super.dispose();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _nacimiento ?? DateTime(hoy.year - 18),
      firstDate: DateTime(1940),
      lastDate: hoy,
    );
    if (f == null) return;
    setState(() {
      _nacimiento = f;
      _fecha.text = DateFormat('dd/MM/yyyy').format(f);
    });
  }

  String? _validar() {
    if (_nombres.text.trim().isEmpty || _apellidos.text.trim().isEmpty)
      return 'Escribe tus nombres y apellidos.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(_correo.text.trim()))
      return 'Correo electrónico no válido.';
    if (_password.text.length < 6)
      return 'La contraseña debe tener mínimo 6 caracteres.';
    if (_password.text != _confirmar.text)
      return 'Las contraseñas no coinciden.';
    return null;
  }

  Future<void> _crear() async {
    final error = _validar();
    if (error != null) {
      _aviso(error);
      return;
    }

    final fecha = _nacimiento == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(_nacimiento!);

    // El barbero completa su perfil en la siguiente pantalla.
    if (_rol == 2) {
      final datos = {
        'nombres': _nombres.text.trim(),
        'apellidos': _apellidos.text.trim(),
        'correo': _correo.text.trim(),
        'telefono': _telefono.text.trim(),
        'fecha_nacimiento': fecha,
        'password': _password.text,
      };
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BarberRegisterScreen(datos: datos)),
      );
      return;
    }

    setState(() => _cargando = true);
    final r = await _servicio.registrar(
      rolId: 3,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      password: _password.text,
      telefono: _telefono.text,
      fechaNacimiento: fecha,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (r['success'] == true) {
      _aviso('Cuenta creada. Ya puedes iniciar sesión.');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      _aviso(r['message']?.toString() ?? 'No se pudo crear la cuenta.');
    }
  }

  // Campo con separación superior, para no repetir SizedBox.
  Widget _f(
    String label,
    String hint,
    IconData icono,
    TextEditingController c, {
    bool password = false,
    TextInputType? teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppField(
        label: label,
        hint: hint,
        icon: icono,
        controller: c,
        password: password,
        keyboard: teclado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                label: const Text('Atrás'),
              ),
              Center(
                child: Text(
                  'CREAR CUENTA',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Vive una experiencia premium en Barber King',
                  style: TextStyle(color: AppColors.subtitle, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TIPO DE CUENTA',
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _rol,
                dropdownColor: AppColors.card,
                iconEnabledColor: AppColors.primary,
                items: const [
                  DropdownMenuItem(value: 3, child: Text('Cliente')),
                  DropdownMenuItem(value: 2, child: Text('Barbero')),
                ],
                onChanged: (v) => setState(() => _rol = v ?? 3),
              ),
              _f('Nombres', 'Tus nombres', Icons.person_outline, _nombres),
              _f(
                'Apellidos',
                'Tus apellidos',
                Icons.person_outline,
                _apellidos,
              ),
              _f(
                'Correo electrónico',
                'correo@ejemplo.com',
                Icons.mail_outline,
                _correo,
                teclado: TextInputType.emailAddress,
              ),
              _f(
                'Teléfono',
                '+57 300 000 0000',
                Icons.phone_outlined,
                _telefono,
                teclado: TextInputType.phone,
              ),
              GestureDetector(
                onTap: _elegirFecha,
                child: AbsorbPointer(
                  child: _f(
                    'Fecha de nacimiento',
                    'DD/MM/AAAA',
                    Icons.calendar_today_outlined,
                    _fecha,
                  ),
                ),
              ),
              _f(
                'Contraseña',
                '••••••••',
                Icons.lock_outline,
                _password,
                password: true,
              ),
              _f(
                'Confirmar contraseña',
                '••••••••',
                Icons.lock_outline,
                _confirmar,
                password: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : _crear,
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.black,
                        ),
                      )
                    : Text(_rol == 2 ? 'CONTINUAR' : 'CREAR CUENTA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
