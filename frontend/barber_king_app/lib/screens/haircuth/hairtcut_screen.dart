import 'package:flutter/material.dart';

class HaircutScreen extends StatelessWidget {
  const HaircutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezado con título y botón de regreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
                  onPressed: () => Navigator.pop(context),
                ),
                Center(
                  child: const Text(
                    'HAIRCUT', 
                    style: TextStyle(
                      color: Color(0xFFD4AF37), 
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de búsqueda
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search haircut...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
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
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
      // Barra de navegación inferior idéntica a la del Home
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border(
            top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
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
      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  );

  // Tarjeta con el estilo idéntico al de la pantalla principal (Home)
  Widget _haircutCard(String title, String subtitle, String price) => Container(
    width: 155,
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF1E293B), 
      borderRadius: BorderRadius.circular(16), 
      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Contenedor de la imagen grande
        Container(
          height: 140, 
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800], 
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.content_cut, color: Colors.white54, size: 40),
          ),
        ),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 9)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  // Elemento de la barra de navegación inferior
  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFFD4AF37) : Colors.white60, size: 28),
        const SizedBox(height: 4),
        Text(
          label, 
          style: TextStyle(
            color: active ? const Color(0xFFD4AF37) : Colors.white60, 
            fontSize: 11, 
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}