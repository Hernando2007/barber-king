part of '../../screens/auth/register_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _RegistroLogica on _RegisterScreenState {
  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_password.text != _confirmar.text) {
      showAppSnack(context, 'Las contraseñas no coinciden.', error: true);
      return;
    }

    setState(() => _cargando = true);

    final esBarbero = _rol == 2;
    final diplomaBytes = esBarbero && _diploma != null
        ? await _diploma!.readAsBytes()
        : null;

    final fotos = <Uint8List>[];
    final nombresFoto = <String>[];

    if (esBarbero) {
      for (final archivo in _fotos) {
        fotos.add(await archivo.readAsBytes());
        nombresFoto.add(archivo.name);
      }
    }

    final respuesta = await _auth.registrar(
      rolId: _rol,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      telefono: _telefono.text,
      fechaNacimiento: _fecha.text,
      password: _password.text,
      especialidad: esBarbero ? _especialidad.text : null,
      experiencia: esBarbero ? int.tryParse(_experiencia.text.trim()) : null,
      descripcion: esBarbero ? _descripcion.text : null,
      diplomaBytes: diplomaBytes,
      diplomaNombre: _diploma?.name,
      fotosTrabajo: fotos,
      nombresFoto: nombresFoto,
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (respuesta['success'] != true) {
      showAppSnack(
        context,
        respuesta['message'] ?? 'No se pudo crear la cuenta.',
        error: true,
      );
      return;
    }

    // La sesión ya está guardada: se entra derecho a la app. El aviso de
    // las fotos se encola antes de navegar para que se vea en el home.
    final publicadas = respuesta['fotosPublicadas'] as int?;
    final aviso = respuesta['fotosMensaje']?.toString();

    if (aviso != null) {
      showAppSnack(context, aviso, error: true);
    } else if ((publicadas ?? 0) > 0) {
      showAppSnack(context, '$publicadas fotos ya están en tu portafolio.');
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _onChangedRol(int value) {
    setState(() {
      _rol = value;

      if (_rol != 2) {
        _diploma = null;
        _fotos = [];
        _especialidad.clear();
        _experiencia.clear();
        _descripcion.clear();
      }
    });
  }

  void _togglePassword() =>
      setState(() => _ocultarPassword = !_ocultarPassword);

  void _toggleConfirmar() =>
      setState(() => _ocultarConfirmar = !_ocultarConfirmar);

  void _onDiplomaChanged(XFile? file) => setState(() => _diploma = file);

  void _onFotosChanged(List<XFile> fotos) => setState(() => _fotos = fotos);
}
