import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/barbero_service.dart';

class BarbersScreen extends StatelessWidget {
  const BarbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezado: Botón de retroceso a la izquierda y Título alineado a la derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'BARBERS',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de búsqueda
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search barber...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Master Barbers
            const Text(
              'MASTER BARBERS',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            // Tarjetas en formato de bloques anchos orientados verticalmente hacia abajo
            _barberBlockCard('Junior', 'Master Barber & Fade Expert', '4.9', '5 Years Exp.'),
            const SizedBox(height: 16),
            _barberBlockCard('Carlos VIP', 'Stylist & Beard Specialist', '4.8', '4 Years Exp.'),
            const SizedBox(height: 16),
            _barberBlockCard('Alejo', 'Classic Cut & Design', '4.7', '3 Years Exp.'),
          ],
        ),
      ),
      // Barra de navegación inferior
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

  // Tarjeta en bloque ancho vertical (foto arriba, datos abajo y estrella a la derecha)
  Widget _barberBlockCard(String name, String role, String rating, String experience) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen / Avatar grande estilo bloque superior
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 60),
          ),
          const SizedBox(height: 14),
          
          // Fila inferior: Nombre/Rol a la izquierda y Calificación a la derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna con Nombre, Rol y Años de experiencia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      experience,
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Calificación con estrella a la derecha
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFD4AF37), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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