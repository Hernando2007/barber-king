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

  Widget _tarjeta(Map<String, dynamic> b) {
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: FotoRed(
                url: fotoBarbero(b),
                ancho: 80,
                alto: 80,
                circular: true,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              nombreBarbero(b),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              especialidad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.subtitle, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            ),
            Text(
              '$total reseña${total == 1 ? '' : 's'}',
              style: const TextStyle(color: AppColors.subtitle, fontSize: 10),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('DESCUBRE BARBEROS', style: tituloSerif(size: 22)),
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
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                              itemCount: _barberos.length,
                              itemBuilder: (_, i) => _tarjeta(_barberos[i]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
