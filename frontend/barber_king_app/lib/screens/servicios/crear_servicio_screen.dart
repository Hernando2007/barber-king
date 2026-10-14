import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/common/app_field.dart';
import '../../widgets/common/gold_widgets.dart';

/// Crea un servicio, o lo edita si recibe [servicios]. La foto se sube a Cloudinary.
class CrearServicioScreen extends StatefulWidget {
  final Map<String, dynamic>? servicio;

  const CrearServicioScreen({super.key, this.servicio});

  @override
  State<CrearServicioScreen> createState() => _CrearServicioScreenState();
}

class _CrearServicioScreenState extends State<CrearServicioScreen> {
  bool get _edita => widget.servicio != null;
  String _dato(String clave) => '${widget.servicio?[clave] ?? ''}';

  late final _nombre = TextEditingController(text: _dato('nombre'));
  late final _descripcion = TextEditingController(text: _dato('descripcion'));
  late final _precio = TextEditingController(
    text: _edita
        ? (num.tryParse(_dato('precio'))?.round().toString() ?? '')
        : '',
  );
  late final _duracion = TextEditingController(text: _dato('duracion'));
  final _servicios = ServicioService();
  XFile? _foto;
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _precio, _duracion]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _elegirFoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (f != null) setState(() => _foto = f);
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final precio = double.tryParse(_precio.text.trim());
    final duracion = int.tryParse(_duracion.text.trim());

    if (nombre.isEmpty ||
        precio == null ||
        precio <= 0 ||
        duracion == null ||
        duracion <= 0) {
      _aviso('Nombre, precio y duración (en minutos) son obligatorios.');
      return;
    }
    setState(() => _guardando = true);

    String? imagen = _edita ? widget.servicio!['imagen']?.toString() : null;
    if (_foto != null) {
      imagen = await UploadService().subirImagen(_foto!.path);
      if (imagen == null) {
        if (mounted) setState(() => _guardando = false);
        _aviso('No se pudo subir la imagen. Intenta de nuevo.');
        return;
      }
    }

    final r = _edita
        ? await _servicios.actualizarServicio(
            id: widget.servicio!['id'] as int,
            datos: {
              'nombre': nombre,
              'descripcion': _descripcion.text.trim(),
              'precio': precio,
              'duracion': duracion,
              'imagen': imagen,
            },
          )
        : await _servicios.crearServicio(
            nombre: nombre,
            descripcion: _descripcion.text.trim(),
            precio: precio,
            duracion: duracion,
            imagen: imagen,
          );
    if (!mounted) return;
    setState(() => _guardando = false);

    if (r['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _aviso('${r['message'] ?? 'No se pudo guardar el servicio.'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    const sep = SizedBox(height: 12);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: Text(
                    _edita ? 'EDITAR SERVICIO' : 'NUEVO SERVICIO',
                    style: tituloSerif(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _elegirFoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _foto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_foto!.path),
                            width: double.infinity,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        )
                      : FotoRed(
                          url: _edita ? _dato('imagen') : null,
                          ancho: double.infinity,
                          alto: 170,
                          radio: 14,
                        ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.photo_camera, color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Nombre del servicio',
              hint: 'Corte clásico',
              icon: Icons.content_cut,
              controller: _nombre,
            ),
            sep,
            AppField(
              label: 'Descripción',
              hint: 'Detalles del servicio',
              icon: Icons.notes,
              controller: _descripcion,
            ),
            sep,
            AppField(
              label: 'Precio (COP)',
              hint: '25000',
              icon: Icons.attach_money,
              controller: _precio,
              keyboard: TextInputType.number,
            ),
            sep,
            AppField(
              label: 'Duración (minutos)',
              hint: '30',
              icon: Icons.timer_outlined,
              controller: _duracion,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.black,
                      ),
                    )
                  : Text(_edita ? 'GUARDAR CAMBIOS' : 'CREAR SERVICIO'),
            ),
          ],
        ),
      ),
    );
  }
}
