part of '../../screens/perfil/perfil_screen.dart';

class _PerfilEditSheet extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final bool esBarbero;

  const _PerfilEditSheet({
    required this.usuario,
    required this.esBarbero,
  });

  @override
  State<_PerfilEditSheet> createState() => _PerfilEditSheetState();
}

class _PerfilEditSheetState extends State<_PerfilEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usuarios = UsuarioService();
  final _auth = AuthService();

  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _telefono;
  late final TextEditingController _fecha;
  late final TextEditingController _especialidad;
  late final TextEditingController _experiencia;
  late final TextEditingController _descripcion;
  late final TextEditingController _direccion;

  bool _guardando = false;

  Map<String, dynamic> get _barbero {
    final value = widget.usuario['barbero'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  @override
  void initState() {
    super.initState();
    final barbero = _barbero;

    _nombres = TextEditingController(
      text: widget.usuario['nombres']?.toString(),
    );
    _apellidos = TextEditingController(
      text: widget.usuario['apellidos']?.toString(),
    );
    _telefono = TextEditingController(
      text: widget.usuario['telefono']?.toString(),
    );
    _fecha = TextEditingController(
      text: widget.usuario['fecha_nacimiento']?.toString().split('T').first,
    );
    _especialidad = TextEditingController(
      text: barbero['especialidad']?.toString(),
    );
    _experiencia = TextEditingController(
      text: barbero['experiencia']?.toString(),
    );
    _descripcion = TextEditingController(
      text: barbero['descripcion']?.toString(),
    );
    _direccion = TextEditingController(
      text: barbero['direccion']?.toString(),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _telefono,
      _fecha,
      _especialidad,
      _experiencia,
      _descripcion,
      _direccion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final datos = <String, dynamic>{
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'telefono': _telefono.text.trim(),
      'fecha_nacimiento': _fecha.text.trim(),
    };

    if (widget.esBarbero) {
      datos.addAll({
        'especialidad': _especialidad.text.trim(),
        'experiencia': int.tryParse(_experiencia.text.trim()) ?? 0,
        'descripcion': _descripcion.text.trim(),
        'direccion': _direccion.text.trim(),
      });
    }

    final respuesta = await _usuarios.actualizarPerfil(datos);

    if (!mounted) return;

    setState(() => _guardando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Perfil actualizado.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _auth.actualizarUsuarioLocal({
        'nombres': datos['nombres'],
        'apellidos': datos['apellidos'],
        'telefono': datos['telefono'],
      });

      if (mounted) Navigator.pop(context, true);
    }
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: _PerfilEditView(
          nombres: _nombres,
          apellidos: _apellidos,
          telefono: _telefono,
          fecha: _fecha,
          especialidad: _especialidad,
          experiencia: _experiencia,
          descripcion: _descripcion,
          direccion: _direccion,
          esBarbero: widget.esBarbero,
          guardando: _guardando,
          requerido: _requerido,
          onGuardar: _guardar,
          onSeleccionarFecha: _seleccionarFecha,
        ),
      ),
    );
  }
}
