import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Barra inferior de 5 pestañas del diseño (cliente).
class AppBottomNav extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.actual, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 'INICIO'),
    (Icons.search, Icons.search, 'BUSCAR'),
    (Icons.person_outline, Icons.person, 'PERFIL'),
    (Icons.photo_camera_outlined, Icons.photo_camera, 'CÁMARA IA'),
    (Icons.shopping_bag_outlined, Icons.shopping_bag, 'RESERVAR'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i == actual ? _items[i].$2 : _items[i].$1,
                          color: i == actual ? AppColors.primary : Colors.white54,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _items[i].$3,
                          style: TextStyle(
                            color: i == actual ? AppColors.primary : Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
