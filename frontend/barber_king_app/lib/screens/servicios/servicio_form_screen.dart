import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';

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
              AppCard(
                gradient: AppColors.heroGradient,
                borderColor: AppColors.primary.withValues(alpha: .3),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.design_services_outlined,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _esEdicion
                            ? 'Actualiza la información del servicio'
                            : 'Agrega un servicio al catálogo',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precio,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        final precio =
                            double.tryParse((value ?? '').replaceAll(',', '.'));
                        if (precio == null || precio <= 0) {
                          return 'Precio inválido.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duracion,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duración',
                        suffixText: 'min',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      validator: (value) {
                        final duracion = int.tryParse(value?.trim() ?? '');
                        if (duracion == null || duracion <= 0) {
                          return 'Duración inválida.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descanso,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiempo de descanso',
                  suffixText: 'min',
                  prefixIcon: Icon(Icons.coffee_outlined),
                  helperText: 'Tiempo entre citas. Opcional.',
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  title: const Text(
                    'Servicio activo',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Los servicios inactivos no aparecen en las reservas.',
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11.5,
                    ),
                  ),
                ),
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
