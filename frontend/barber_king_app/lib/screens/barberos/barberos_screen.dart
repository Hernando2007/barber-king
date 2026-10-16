import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';

class BarberosScreen extends StatefulWidget {
  const BarberosScreen({super.key});

  @override
  State<BarberosScreen> createState() => _BarberosScreenState();
}

class _BarberosScreenState extends State<BarberosScreen> {
  List<Map<String, dynamic>> _barberos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await BarberoService().obtenerBarberos();
    if (!mounted) return;
    setState(() {
      _barberos = lista
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _cargando = false;
    });
  }

 /// Tarjeta ancha con mayor altura
  Widget _tarjetaAncha(Map<String, dynamic> b) {
    final promedio = (b['calificacion_promedio'] as num?)?.toDouble() ?? 0;
    final total = int.tryParse('${b['total_resenas'] ?? 0}') ?? 0;
    final especialidad = '${b['especialidad'] ?? 'Barbero profesional'}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CrearCitaScreen(barberoInicialId: int.tryParse('${b['id']}')),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        // Aumentamos el padding vertical (de 14 a 18 o 20) para darle más altura a la card
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            // Foto circular del barbero con un tamaño ligeramente mayor si deseas (ej: 76)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: FotoRed(
                url: fotoBarbero(b),
                ancho: 76,
                alto: 76,
                circular: true,
              ),
            ),
            const SizedBox(width: 16),
            // Detalles del barbero
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreBarbero(b),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16, // Texto un poco más prominente
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    especialidad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        promedio > 0 ? promedio.toStringAsFixed(1) : 'Nuevo',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($total reseña${total == 1 ? '' : 's'})',
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Indicador a la derecha
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Título principal con fuente normal sans-serif
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'DESCUBRE BARBEROS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Divider(
              color: AppColors.border.withValues(alpha: 0.6),
              indent: 16,
              endIndent: 16,
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: _barberos.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Aún no hay barberos disponibles.',
                                    style: TextStyle(color: AppColors.subtitle),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _barberos.length,
                              itemBuilder: (_, i) => _tarjetaAncha(_barberos[i]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}