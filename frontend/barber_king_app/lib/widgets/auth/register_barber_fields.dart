import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'barber_registration_fields.dart';

class RegisterBarberFields extends StatefulWidget {
  final bool visible;
  final TextEditingController especialidad;
  final TextEditingController experiencia;
  final TextEditingController descripcion;
  final String? diplomaName;
  final ValueChanged<XFile?> onDiplomaChanged;
  final List<XFile> fotos;
  final ValueChanged<List<XFile>> onFotosChanged;

  const RegisterBarberFields({
    super.key,
    required this.visible,
    required this.especialidad,
    required this.experiencia,
    required this.descripcion,
    required this.diplomaName,
    required this.onDiplomaChanged,
    required this.fotos,
    required this.onFotosChanged,
  });

  @override
  State<RegisterBarberFields> createState() => _RegisterBarberFieldsState();
}

class _RegisterBarberFieldsState extends State<RegisterBarberFields> {
  static const int _limiteFotos = 6;

  final _picker = ImagePicker();

  Future<void> _seleccionarDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    widget.onDiplomaChanged(file);
  }

  Future<void> _seleccionarFotos() async {
    final restantes = _limiteFotos - widget.fotos.length;

    if (restantes <= 0) return;

    final elegidas = await _picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 1400,
      maxHeight: 1400,
    );

    if (elegidas.isEmpty || !mounted) return;

    widget.onFotosChanged([...widget.fotos, ...elegidas.take(restantes)]);
  }

  void _quitarFoto(XFile archivo) {
    widget.onFotosChanged(
      widget.fotos.where((foto) => foto.path != archivo.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        BarberRegistrationFields(
          specialtyController: widget.especialidad,
          experienceController: widget.experiencia,
          descriptionController: widget.descripcion,
          diplomaName: widget.diplomaName,
          onPickDiploma: _seleccionarDiploma,
          onRemoveDiploma: () => widget.onDiplomaChanged(null),
          fotos: widget.fotos,
          limiteFotos: _limiteFotos,
          onPickFotos: _seleccionarFotos,
          onQuitarFoto: _quitarFoto,
        ),
      ],
    );
  }
}
