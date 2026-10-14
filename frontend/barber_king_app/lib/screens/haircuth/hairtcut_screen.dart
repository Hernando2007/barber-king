import 'package:flutter/material.dart';
import '../../core/colors.dart';

class HaircutScreen extends StatelessWidget {
  const HaircutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezado con título y botón de regreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'HAIRCUT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Espacio para equilibrar el icono de atrás
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de búsqueda
            TextField(
              style: const TextStyle(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Search haircut...',
                hintStyle: TextStyle(color: AppColors.subtitle.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search, color: AppColors.subtitle),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // Categorías horizontales de filtros
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip('All Styles', true),
                  _categoryChip('Fade', false),
                  _categoryChip('Modern', false),
                  _categoryChip('Classic', false),
                  _categoryChip('Beard', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección 1: Destacados / Tendencias
            const Text(
              'TRENDING STYLES',
              style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 275,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _haircutCard('DESVANECEDOR', 'Junior, VIP\nRecommendation', '\$25.000'),
                  _haircutCard('SIETE', 'Siete, VIP\nRecommendation', '\$22.000'),
                  _haircutCard('MOHICANO', 'Mohicano, VIP\nRecommendation', '\$28.000'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección 2: Clásicos y otros estilos
            const Text(
              'CLASSIC & BEARD',
              style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 275,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _haircutCard('LOW FADE', 'Clean & Fresh\nRecommendation', '\$24.000'),
                  _haircutCard('CLASSIC CUT', 'Traditional\nRecommendation', '\$20.000'),
                  _haircutCard('BEARD TRIM', 'Full Grooming\nRecommendation', '\$18.000'),
                ],
              ),
            ),
          ],
        ),
      ),
      // Barra de navegación inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, 'HOME', false, () => Navigator.pop(context)),
            _navItem(Icons.search, 'SEARCH', false, () {}),
            _navItem(Icons.person_outline, 'PROFILE', false, () {}),
            _navItem(Icons.camera_alt_outlined, 'CAMERA IA', false, () {}),
            _navItem(Icons.calendar_today_outlined, 'BOOK', false, () {}),
          ],
        ),
      ),
    );
  }

  // Chip de categoría superior
  Widget _categoryChip(String label, bool isSelected) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  );

  // Tarjeta de corte adaptada a modo claro
 // Tarjeta de corte optimizada para mejor visualización del nombre
  Widget _haircutCard(String title, String subtitle, String price) => Container(
    width: 172, // Ancho ampliado para que el nombre quepa holgadamente
    margin: const EdgeInsets.only(right: 14),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.card, 
      borderRadius: BorderRadius.circular(16), 
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 125, // Altura de la imagen ajustada proporcionalmente
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface, 
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.content_cut, color: AppColors.subtitle, size: 36),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primary, 
            fontSize: 13, 
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle, 
          textAlign: TextAlign.center, 
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.subtitle, 
            fontSize: 9,
            height: 1.1,
          ),
        ),
        const Spacer(),
        Text(
          price, 
          style: const TextStyle(
            color: AppColors.primary, 
            fontSize: 12, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  // Elemento de la barra de navegación inferior
  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? AppColors.primary : AppColors.subtitle, size: 26),
        const SizedBox(height: 4),
        Text(
          label, 
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.subtitle, 
            fontSize: 10, 
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}