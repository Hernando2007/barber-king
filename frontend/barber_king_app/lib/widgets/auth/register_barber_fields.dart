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

  const RegisterBarberFields({
    super.key,
    required this.visible,
    required this.especialidad,
    required this.experiencia,
    required this.descripcion,
    required this.diplomaName,
    required this.onDiplomaChanged,
  });

  @override
  State<RegisterBarberFields> createState() => _RegisterBarberFieldsState();
}

class _RegisterBarberFieldsState extends State<RegisterBarberFields> {
  final _picker = ImagePicker();

  Future<void> _seleccionarDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    widget.onDiplomaChanged(file);
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
        ),
      ],
    );
  }
}
