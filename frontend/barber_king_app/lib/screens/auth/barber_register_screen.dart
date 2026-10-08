import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/registro_service.dart';
import '../../widgets/common/app_field.dart';

/// Paso 2 del registro de barbero. Recibe los datos de la pantalla "Crear cuenta".
class BarberRegisterScreen extends StatefulWidget {
  final Map<String, String> datos;

  const BarberRegisterScreen({super.key, required this.datos});

  @override
  State<BarberRegisterScreen> createState() => _BarberRegisterScreenState();
}

class _BarberRegisterScreenState extends State<BarberRegisterScreen> {
  static const _maxFotos = 9;

  late final _nombre = TextEditingController(
    text: '${widget.datos['nombres']} ${widget.datos['apellidos']}',
  );
  late final _telefono = TextEditingController(text: widget.datos['telefono']);
  late final _correo = TextEditingController(text: widget.datos['correo']);
  final _direccion = TextEditingController();
  final _experiencia = TextEditingController();
  final _servicio = RegistroService();
  final List<XFile> _fotos = [];
  bool _cargando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _correo, _direccion, _experiencia]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _agregarFotos() async {
    final elegidas = await ImagePicker().pickMultiImage(
      imageQuality: 80,
      limit: _maxFotos,
    );
    if (elegidas.isEmpty) return;
    setState(() {
      _fotos.addAll(elegidas);
      if (_fotos.length > _maxFotos) {
        _fotos.removeRange(_maxFotos, _fotos.length);
      }
    });
  }

  Future<void> _enviar() async {
    if (_direccion.text.trim().isEmpty) {
      _aviso('Escribe la dirección de tu local o barbería.');
      return;
    }

    setState(() => _cargando = true);
    final d = widget.datos;
    final r = await _servicio.registrar(
      rolId: 2,
      nombres: d['nombres'] ?? '',
      apellidos: d['apellidos'] ?? '',
      correo: d['correo'] ?? '',
      password: d['password'] ?? '',
      telefono: d['telefono'] ?? '',
      fechaNacimiento: d['fecha_nacimiento'] ?? '',
      especialidad: 'Barbería general',
      experiencia: int.tryParse(_experiencia.text.trim()) ?? 0,
      direccion: _direccion.text,
      portafolio: _fotos.map((f) => f.path).toList(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (r['success'] == true) {
      _aviso('Registro enviado. Inicia sesión para continuar.');
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } else {
      _aviso(r['message']?.toString() ?? 'No se pudo enviar el registro.');
    }
  }

  Widget _casilla(int i) {
    if (i < _fotos.length) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(_fotos[i].path), fit: BoxFit.cover),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => setState(() => _fotos.removeAt(i)),
              child: const Icon(
                Icons.cancel,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    }

    final esAgregar = i == _fotos.length;
    return GestureDetector(
      onTap: esAgregar ? _agregarFotos : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Icon(
          esAgregar ? Icons.add : Icons.image_outlined,
          color: esAgregar ? AppColors.primary : Colors.white24,
          size: esAgregar ? 28 : 22,
        ),
      ),
    );
  }

  Widget _seccion(String titulo, Widget hijo) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          hijo,
        ],
      ),
    );
  }

  Widget _f(
    String label,
    String hint,
    IconData icono,
    TextEditingController c, {
    TextInputType? teclado,
  }) {
    final campo = AppField(
      label: label,
      hint: hint,
      icon: icono,
      controller: c,
      keyboard: teclado,
    );
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: campo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                    label: const Text('Atrás'),
                  ),
                  Expanded(
                    child: Text(
                      'REGISTRO BARBERO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
              const SizedBox(height: 8),
              _seccion(
                'INFORMACIÓN PERSONAL',
                AbsorbPointer(
                  child: Column(
                    children: [
                      _f('Nombre', '', Icons.person_outline, _nombre),
                      _f('Teléfono', '', Icons.phone_outlined, _telefono),
                      _f('Email', '', Icons.mail_outline, _correo),
                    ],
                  ),
                ),
              ),
              _seccion(
                'UBICACIÓN Y EXPERIENCIA',
                Column(
                  children: [
                    _f(
                      'Local / Barbería',
                      'Calle de Alcalá, 12',
                      Icons.storefront_outlined,
                      _direccion,
                    ),
                    _f(
                      'Experiencia en años',
                      'Ej: 5',
                      Icons.workspace_premium_outlined,
                      _experiencia,
                      teclado: TextInputType.number,
                    ),
                  ],
                ),
              ),
              _seccion(
                'MI PORTAFOLIO - SUBIR CORTES',
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(_maxFotos, _casilla),
                ),
              ),
              ElevatedButton(
                onPressed: _cargando ? null : _enviar,
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.black,
                        ),
                      )
                    : const Text('ENVIAR REGISTRO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
