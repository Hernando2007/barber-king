import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BarberRegistrationFields extends StatelessWidget {
  final TextEditingController specialtyController;
  final String? diplomaName;
  final VoidCallback onPickDiploma;
  final VoidCallback onRemoveDiploma;

  const BarberRegistrationFields({
    super.key,
    required this.specialtyController,
    required this.diplomaName,
    required this.onPickDiploma,
    required this.onRemoveDiploma,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Perfil profesional',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: specialtyController,
          decoration: const InputDecoration(
            labelText: 'Especialidad',
            hintText: 'Ej. Fade, barbería clásica, colorimetría...',
            prefixIcon: Icon(Icons.workspace_premium_outlined),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onPickDiploma,
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(
            diplomaName == null
                ? 'Adjuntar diploma o certificado (opcional)'
                : 'Cambiar diploma/certificado',
          ),
        ),
        if (diplomaName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    diplomaName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemoveDiploma,
                  icon: const Icon(Icons.close),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'El documento se guarda para revisión del perfil profesional.',
            style: TextStyle(
              color: AppColors.subtitle,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
