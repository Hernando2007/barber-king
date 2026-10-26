import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BarberRegistrationFields extends StatelessWidget {
  final TextEditingController specialtyController;
  final TextEditingController experienceController;
  final TextEditingController descriptionController;
  final String? diplomaName;
  final VoidCallback onPickDiploma;
  final VoidCallback onRemoveDiploma;

  const BarberRegistrationFields({
    super.key,
    required this.specialtyController,
    required this.experienceController,
    required this.descriptionController,
    required this.diplomaName,
    required this.onPickDiploma,
    required this.onRemoveDiploma,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.primary,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'Perfil profesional',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: specialtyController,
            decoration: const InputDecoration(
              labelText: 'Especialidad *',
              hintText: 'Ej. Fade, barbería clásica, colorimetría',
              prefixIcon: Icon(Icons.content_cut_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La especialidad es obligatoria.';
              }
              return null;
            },
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Años de experiencia',
              hintText: 'Ej. 3',
              prefixIcon: Icon(Icons.timeline_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final years = int.tryParse(value.trim());
              if (years == null || years < 0 || years > 70) {
                return 'Ingresa un valor entre 0 y 70.';
              }
              return null;
            },
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción profesional',
              hintText: 'Cuéntale a tus clientes sobre tu estilo de trabajo.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onPickDiploma,
            icon: const Icon(Icons.upload_file_outlined, size: 19),
            label: Text(
              diplomaName == null
                  ? 'Adjuntar diploma o certificado *'
                  : 'Cambiar documento',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Obligatorio para cuentas de barbero. La IA verifica que sea un '
            'diploma real de barbería; las cuentas con documentos falsos son '
            'rechazadas. Solo imágenes JPG, PNG o WEBP.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          if (diplomaName != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      diplomaName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRemoveDiploma,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
