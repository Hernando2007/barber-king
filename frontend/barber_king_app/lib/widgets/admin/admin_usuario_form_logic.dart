part of '../../screens/admin/admin_usuario_form_screen.dart';

extension _AdminUsuarioFormLogic on _AdminUsuarioFormScreenState {
  Future<void> _seleccionarFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: AppFormat.toDate(_fecha.text) ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (value == null) return;

    _fecha.text =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _datos({bool forzar = false}) {
    final datos = <String, dynamic>{
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'correo': _correo.text.trim(),
      'telefono': _telefono.text.trim(),
      'fecha_nacimiento': _fecha.text.trim(),
      'rol_id': _rol,
      'estado': _activo,
    };

    if (_password.text.trim().isNotEmpty) {
      datos['password'] = _password.text;
    }

    if (_rol == 2) {
      datos.addAll({
        'especialidad': _especialidad.text.trim(),
        'experiencia': int.tryParse(_experiencia.text.trim()) ?? 0,
        'descripcion': _descripcion.text.trim(),
        'direccion': _direccion.text.trim(),
        'disponible': _disponible,
      });
    }

    if (forzar) {
      datos['forzar'] = true;
    }

    return datos;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_esEdicion && _password.text.trim().length < 6) {
      showAppSnack(context, 'La contraseña debe tener mínimo 6 caracteres.',
          error: true);
      return;
    }

    // ignore: invalid_use_of_protected_member
    setState(() => _cargando = true);

    final id = int.tryParse('${widget.usuario?['id']}');
    var respuesta = _esEdicion
        ? await _admin.actualizarUsuario(id ?? 0, _datos())
        : await _admin.crearUsuario(_datos());

    if (!mounted) return;

    if (_esEdicion && respuesta['statusCode'] == 409) {
      final mensaje = respuesta['message']?.toString() ?? '';
      final esRol = mensaje.toLowerCase().contains('barbero');

      if (esRol) {
        final forzar = await showConfirmDialog(
          context,
          title: 'Cambio de rol con registros asociados',
          message:
              '$mensaje\n\nSi cambias el rol, se eliminarán las citas, '
              'reseñas y horarios del perfil de barbero.',
          confirmLabel: 'Cambiar de todas formas',
          destructive: true,
        );

        if (forzar) {
          respuesta = await _admin.actualizarUsuario(
            id ?? 0,
            _datos(forzar: true),
          );
        }
      }
    }

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _cargando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ??
          (_esEdicion ? 'Usuario actualizado.' : 'Usuario creado.'),
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }
}
