import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Campo del diseño Figma: etiqueta en mayúsculas arriba, borde dorado fino.
class AppField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool password;
  final TextInputType? keyboard;

  const AppField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.password = false,
    this.keyboard,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _oculto = true;

  OutlineInputBorder _borde(Color color, [double ancho = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: ancho),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.subtitle,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboard,
          obscureText: widget.password && _oculto,
          cursorColor: AppColors.primary,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: Icon(widget.icon, color: AppColors.primary, size: 20),
            suffixIcon: widget.password
                ? IconButton(
                    onPressed: () => setState(() => _oculto = !_oculto),
                    icon: Icon(
                      _oculto
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.subtitle,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: _borde(AppColors.border),
            enabledBorder: _borde(AppColors.border),
            focusedBorder: _borde(AppColors.primary, 1.5),
          ),
        ),
      ],
    );
  }
}
