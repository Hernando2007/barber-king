import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../haircuth/hairtcut_screen.dart';
import '../barberos/barberos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo blanco limpio
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text(
                'BARBER KING',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Barra de búsqueda adaptada a modo claro
            TextField(
              style: const TextStyle(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.subtitle.withOpacity(0.6)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.subtitle,
                ),
                suffixIcon: const Icon(Icons.tune, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
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
                      MaterialPageRoute(
                        builder: (context) => const HaircutScreen(),
                      ),
                    );
                  },
                  child: _topBtn(Icons.content_cut, 'HAIRCUT', false),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarberosScreen(),
                      ),
                    );
                  },
                  child: _topBtn(Icons.person_outline, 'BARBERS', false),
                ),
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
              _card(
                'DESVANECEDOR',
                'Junior, VIP\nRecommendation',
                0,
                isHaircut: true,
              ),
              _card('SIETE', 'Siete, VIP\nRecommendation', 0, isHaircut: true),
              _card(
                'MOHICANO',
                'Mohicano, VIP\nRecommendation',
                0,
                isHaircut: true,
              ),
            ]),
          ],
        ),
      ),
      // Barra de navegación inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface, // Mismo fondo uniforme para todos
          border: Border.all(
            color: AppColors.border, // Mismo borde sutil para todos
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.primary, // Ícono oscuro consistente
          size: 30,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.subtitle, // Texto uniforme y legible
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
  Widget _sectionTitle(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const Icon(Icons.chevron_right, color: AppColors.primary),
    ],
  );

  Widget _buildHorizontalList(List<Widget> children) => SizedBox(
    height: 275,
    child: ListView(scrollDirection: Axis.horizontal, children: children),
  );

  Widget _card(
    String title,
    String subtitle,
    int rating, {
    bool isHaircut = false,
  }) => Container(
    width: 155,
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, color: AppColors.subtitle, size: 40),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isHaircut ? AppColors.primaryLight : AppColors.subtitle,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!isHaircut) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.amber[750] ?? Colors.orange,
                size: 12,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _navItem(IconData icon, String label, bool active) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: active ? AppColors.primary : AppColors.subtitle,
        size: 26,
      ),
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
  );
}