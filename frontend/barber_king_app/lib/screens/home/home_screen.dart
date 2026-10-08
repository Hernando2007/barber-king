import 'package:flutter/material.dart';
import '../haircuth/hairtcut_screen.dart';
import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text('BARBER KING', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
            const SizedBox(height: 20),
            
            // Barra de búsqueda
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                suffixIcon: const Icon(Icons.tune, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),

            // Botones superiores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HaircutScreen()),
        );
      },
      child: _topBtn(Icons.content_cut, 'HAIRCUT', false),
    ),
                _topBtn(Icons.person_outline, 'BARBERS', false),
                _topBtn(Icons.star, 'VIP', true),
              ],
            ),
            const SizedBox(height: 32),

            // Sección Barberos
            _sectionTitle('BARBERS'),
            const SizedBox(height: 10),
            _buildHorizontalList([
              _card('BARBER JUNIOR', 'Junior, VIP', 4),
              _card('BARBER ALEX', 'Master, VIP', 5),
              _card('BARBER ANDRES', 'Senior Stylist', 5),
            ]),
            
            const SizedBox(height: 28),
            
            // Sección Cortes
            _sectionTitle('HAIRCUT'),
            const SizedBox(height: 10),
            _buildHorizontalList([
              _card('DESVANECEDOR', 'Junior, VIP\nRecommendation', 0, isHaircut: true),
              _card('SIETE', 'Siete, VIP\nRecommendation', 0, isHaircut: true),
              _card('MOHICANO', 'Mohicano, VIP\nRecommendation', 0, isHaircut: true),
            ]),
          ],
        ),
      ),
      // Barra de navegación inferior ampliada y estilizada
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Un tono ligeramente más claro para destacarla
          border: Border(
            top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, 'HOME', true),
            _navItem(Icons.search, 'SEARCH', false),
            _navItem(Icons.person_outline, 'PROFILE', false),
            _navItem(Icons.camera_alt_outlined, 'CAMERA IA', false),
            _navItem(Icons.calendar_today_outlined, 'BOOK', false),
          ],
        ),
      ),
    );
  }

  Widget _topBtn(IconData icon, String label, bool active) => Column(
    children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(shape: BoxShape.circle, color: active ? const Color(0xFFD4AF37) : const Color(0xFF1E293B), border: Border.all(color: const Color(0xFFD4AF37))),
        child: Icon(icon, color: active ? const Color(0xFF0F172A) : const Color(0xFFD4AF37), size: 30),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(color: active ? const Color(0xFFD4AF37) : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _sectionTitle(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
    ],
  );

  Widget _buildHorizontalList(List<Widget> children) => SizedBox(
    height: 275,
    child: ListView(scrollDirection: Axis.horizontal, children: children),
  );

  Widget _card(String title, String subtitle, int rating, {bool isHaircut = false}) => Container(
    width: 155,
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 160, 
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800], 
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image, color: Colors.white54, size: 45),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: isHaircut ? const Color(0xFFD4AF37) : Colors.white54, fontSize: 9)),
        if (!isHaircut) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: const Color(0xFFD4AF37), size: 12)),
          ),
        ],
      ],
    ),
  );

  // Elementos de la barra inferior más grandes y cómodos
  Widget _navItem(IconData icon, String label, bool active) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: active ? const Color(0xFFD4AF37) : Colors.white60, size: 28), // Icono más grande (28)
      const SizedBox(height: 4),
      Text(
        label, 
        style: TextStyle(
          color: active ? const Color(0xFFD4AF37) : Colors.white60, 
          fontSize: 11, // Texto ligeramente más legible
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}