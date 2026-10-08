import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'gold_widgets.dart';

/// Caja con título, usada para agrupar secciones (catálogo, reservar cita).
class CajaSeccion extends StatelessWidget {
  final String titulo;
  final Widget hijo;

  const CajaSeccion(this.titulo, this.hijo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(titulo, style: tituloSerif(size: 13)), const SizedBox(height: 10), hijo],
      ),
    );
  }
}

class EtiquetaCampo extends StatelessWidget {
  final String texto;

  const EtiquetaCampo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(texto.toUpperCase(),
            style: const TextStyle(color: AppColors.subtitle, fontSize: 10, letterSpacing: 0.8)),
      );
}

class IconoCirculo extends StatelessWidget {
  final IconData icono;
  final double tam;

  const IconoCirculo(this.icono, {super.key, this.tam = 64});

  @override
  Widget build(BuildContext context) => Container(
        width: tam,
        height: tam,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary)),
        child: Icon(icono, color: AppColors.primary, size: tam * 0.45),
      );
}

/// Carrusel horizontal de servicios (foto redonda, nombre y precio).
class ServiciosSelector extends StatelessWidget {
  final List<Map<String, dynamic>> servicios;
  final int? seleccionado;
  final ValueChanged<Map<String, dynamic>> onSeleccion;

  const ServiciosSelector({super.key, required this.servicios, required this.seleccionado, required this.onSeleccion});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: servicios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = servicios[i];
          final activo = s['id'] == seleccionado;
          return GestureDetector(
            onTap: () => onSeleccion(s),
            child: Container(
              width: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activo ? AppColors.primary : Colors.transparent, width: 1.5),
              ),
              child: Column(children: [
                FotoRed(url: s['imagen']?.toString(), ancho: 46, alto: 46, circular: true),
                const SizedBox(height: 6),
                Text('${s['nombre']}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                Text(precioCOP(num.tryParse('${s['precio']}') ?? 0),
                    style: const TextStyle(color: AppColors.primary, fontSize: 10)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

/// Tira horizontal de fotos cuadradas (portafolio del barbero).
class FotosHorizontal extends StatelessWidget {
  final List<String> urls;
  final double tam;

  const FotosHorizontal(this.urls, {super.key, this.tam = 78});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tam,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final u in urls)
            Padding(padding: const EdgeInsets.only(right: 8), child: FotoRed(url: u, ancho: tam, alto: tam)),
        ],
      ),
    );
  }
}
