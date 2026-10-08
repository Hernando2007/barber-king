import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';

String precioCOP(num valor) =>
    NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0).format(valor);

Map _usuarioDe(Map barbero) => barbero['usuarios'] is Map ? barbero['usuarios'] as Map : const {};

String nombreBarbero(Map barbero) {
  final u = _usuarioDe(barbero);
  return '${u['nombres'] ?? ''} ${u['apellidos'] ?? ''}'.trim();
}

String? fotoBarbero(Map barbero) => _usuarioDe(barbero)['foto']?.toString();

TextStyle tituloSerif({double size = 18, Color color = AppColors.primary}) =>
    GoogleFonts.playfairDisplay(color: color, fontSize: size, fontWeight: FontWeight.w900);

/// Imagen de red con marcador cuando no hay foto o falla la carga.
class FotoRed extends StatelessWidget {
  final String? url;
  final double? ancho;
  final double? alto;
  final bool circular;
  final double radio;

  const FotoRed({super.key, this.url, this.ancho, this.alto, this.circular = false, this.radio = 10});

  String? get _src {
    final u = url?.trim() ?? '';
    if (u.isEmpty) return null;
    if (u.startsWith('http')) return u;
    final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return u.startsWith('/') ? '$base$u' : '$base/$u';
  }

  @override
  Widget build(BuildContext context) {
    const vacio = Center(child: Icon(Icons.content_cut, color: AppColors.border, size: 22));
    final src = _src;
    final imagen = Container(
      width: ancho,
      height: alto,
      color: AppColors.surface,
      child: src == null
          ? vacio
          : Image.network(src, fit: BoxFit.cover, errorBuilder: (_, __, ___) => vacio),
    );
    return circular
        ? ClipOval(child: imagen)
        : ClipRRect(borderRadius: BorderRadius.circular(radio), child: imagen);
  }
}

class Estrellas extends StatelessWidget {
  final double valor;
  final double size;

  const Estrellas({super.key, required this.valor, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(i < valor.round() ? Icons.star : Icons.star_border, size: size, color: AppColors.primary),
      ),
    );
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;

  const TituloSeccion(this.texto, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(texto, style: tituloSerif(size: 17))),
          if (onTap != null)
            GestureDetector(onTap: onTap, child: const Icon(Icons.chevron_right, color: AppColors.primary)),
        ],
      ),
    );
  }
}

/// Buscador redondeado de las pantallas Home y VIP.
class CampoBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const CampoBusqueda({super.key, required this.controller, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: AppColors.primary,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        suffixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        border: borde,
        enabledBorder: borde,
        focusedBorder: borde.copyWith(borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}
