import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';

class ImageSourceSheet extends StatelessWidget {
  final ValueChanged<ImageSource> onSelected;

  const ImageSourceSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(
              Icons.camera_alt,
              color: AppColors.primary,
            ),
            title: const Text('Tomar foto'),
            onTap: () {
              Navigator.pop(context);
              onSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library,
              color: AppColors.primary,
            ),
            title: const Text('Elegir de la galería'),
            onTap: () {
              Navigator.pop(context);
              onSelected(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
