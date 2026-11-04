import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/register_account_type.dart';
import '../../widgets/auth/register_barber_fields.dart';
import '../../widgets/auth/register_fields_sections.dart';
import '../../widgets/auth/register_header.dart';
import '../../widgets/auth/register_submit_buttons.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/auth/register_logica.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

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
  List<XFile> _fotos = [];

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
                  const RegisterHeader(),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RegisterAccountType(
                            value: _rol,
                            onChanged: _onChangedRol,
                          ),
                          const SizedBox(height: 24),
                          RegisterFieldsSections(
                            nombres: _nombres,
                            apellidos: _apellidos,
                            correo: _correo,
                            telefono: _telefono,
                            fecha: _fecha,
                            password: _password,
                            confirmar: _confirmar,
                            ocultarPassword: _ocultarPassword,
                            ocultarConfirmar: _ocultarConfirmar,
                            onTogglePassword: _togglePassword,
                            onToggleConfirmar: _toggleConfirmar,
                          ),
                          RegisterBarberFields(
                            visible: _rol == 2,
                            especialidad: _especialidad,
                            experiencia: _experiencia,
                            descripcion: _descripcion,
                            diplomaName: _diploma?.name,
                            onDiplomaChanged: _onDiplomaChanged,
                            fotos: _fotos,
                            onFotosChanged: _onFotosChanged,
                          ),
                          const SizedBox(height: 26),
                          RegisterSubmitButtons(
                            esBarbero: _rol == 2,
                            cargando: _cargando,
                            onRegister: _registrar,
                            onCancel: () => Navigator.pop(context),
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
}
