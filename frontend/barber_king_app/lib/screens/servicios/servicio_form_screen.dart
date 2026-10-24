import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/servicios/servicio_form_activo_switch.dart';
import '../../widgets/servicios/servicio_form_campos.dart';
import '../../widgets/servicios/servicio_form_header.dart';

class ServicioFormScreen extends StatefulWidget {
  final Map<String, dynamic>? servicio;

  const ServicioFormScreen({super.key, this.servicio});

  @override
  State<ServicioFormScreen> createState() => _ServicioFormScreenState();
}

class _ServicioFormScreenState extends State<ServicioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ServicioService();

  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _duracion;
  late final TextEditingController _descanso;

  late bool _activo;
  bool _cargando = false;

  bool get _esEdicion => widget.servicio != null;

  @override
  void initState() {
    super.initState();

    final servicio = widget.servicio ?? const <String, dynamic>{};

    _nombre = TextEditingController(text: servicio['nombre']?.toString());
    _descripcion = TextEditingController(
      text: servicio['descripcion']?.toString(),
    );
    _precio = TextEditingController(text: servicio['precio']?.toString());
    _duracion = TextEditingController(text: servicio['duracion']?.toString());
    _descanso = TextEditingController(
      text: servicio['tiempo_descanso']?.toString(),
    );
    _activo = servicio['estado'] != false;
  }

  @override
  void dispose() {
    for (final controller in [
      _nombre,
      _descripcion,
      _precio,
      _duracion,
      _descanso,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final datos = {
      'nombre': _nombre.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'precio': double.tryParse(_precio.text.replaceAll(',', '.')) ?? 0,
      'duracion': int.tryParse(_duracion.text.trim()) ?? 0,
      'tiempo_descanso': int.tryParse(_descanso.text.trim()) ?? 0,
      'estado': _activo,
    };

    final respuesta = _esEdicion
        ? await _service.actualizarServicio(
            id: int.tryParse('${widget.servicio?['id']}') ?? 0,
            datos: datos,
          )
        : await _service.crearServicio(
            nombre: datos['nombre'] as String,
            descripcion: datos['descripcion'] as String,
            precio: datos['precio'] as double,
            duracion: datos['duracion'] as int,
            tiempoDescanso: datos['tiempo_descanso'] as int,
            estado: _activo,
          );

    if (!mounted) return;

    setState(() => _cargando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ??
          (_esEdicion ? 'Servicio actualizado.' : 'Servicio creado.'),
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar servicio' : 'Nuevo servicio'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ServicioFormHeader(esEdicion: _esEdicion),
              const SizedBox(height: 22),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio',
                  hintText: 'Ej. Corte fade premium',
                  prefixIcon: Icon(Icons.content_cut_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Ingresa un nombre válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe qué incluye el servicio.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              ServicioFormCampos(
                precio: _precio,
                duracion: _duracion,
                descanso: _descanso,
              ),
              const SizedBox(height: 18),
              ServicioFormActivoSwitch(
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
              ),
              const SizedBox(height: 26),
              PrimaryGradientButton(
                label: _esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR SERVICIO',
                icon: Icons.save_outlined,
                loading: _cargando,
                onPressed: _cargando ? null : _guardar,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
