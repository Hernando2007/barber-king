import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';

/// Las fotos que el barbero quiere publicar apenas crea la cuenta. No son
/// obligatorias: sin diploma, el trabajo habla por él.
class RegistroFotosPortafolio extends StatelessWidget {
  final List<XFile> fotos;
  final int limite;
  final VoidCallback onPick;
  final ValueChanged<XFile> onQuitar;

  const RegistroFotosPortafolio({
    super.key,
    required this.fotos,
    required this.limite,
    required this.onPick,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 13),
        OutlinedButton.icon(
          onPressed: fotos.length >= limite ? null : onPick,
          icon: const Icon(Icons.add_a_photo_outlined, size: 19),
          label: Text(
            fotos.isEmpty
                ? 'Mostrar fotos de tu trabajo'
                : 'Agregar fotos (${fotos.length} de $limite)',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sube hasta 6 cortes reales. Se publican en tu perfil en cuanto '
          'nace la cuenta, y siempre puedes añadir más desde Mis fotos.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        if (fotos.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, indice) => _MiniaturaRegistro(
                archivo: fotos[indice],
                onQuitar: () => onQuitar(fotos[indice]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniaturaRegistro extends StatelessWidget {
  final XFile archivo;
  final VoidCallback onQuitar;

  const _MiniaturaRegistro({required this.archivo, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(archivo.path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.card,
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.muted,
              ),
            ),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: InkWell(
              onTap: onQuitar,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: .66),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
