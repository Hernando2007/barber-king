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
      _barberos = lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _cargando = false;
    });
  }
 
  void _abrirCita([int? barberoId]) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CrearCitaScreen(barberoInicialId: barberoId),
        ),
      );
 
  Widget _tarjeta(Map<String, dynamic> b) {
    final promedio = (b['calificacion_promedio'] as num?)?.toDouble() ?? 0;
    final total = int.tryParse('${b['total_resenas'] ?? 0}') ?? 0;
    final especialidad = '${b['especialidad'] ?? 'Barbero profesional'}';
 
    return GestureDetector(
      onTap: () => _abrirCita(int.tryParse('${b['id']}')),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: FotoRed(url: fotoBarbero(b), ancho: 90, alto: 90, circular: true),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombreBarbero(b),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(especialidad,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.subtitle, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.star, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(promedio > 0 ? promedio.toStringAsFixed(1) : 'Nuevo',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Text('$total reseña${total == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppColors.subtitle, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _encabezado() => Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 48),
              child: Text('BARBEROS', textAlign: TextAlign.center, style: tituloSerif(size: 22)),
            ),
          ),
        ]),
      );
 
  Widget _navItem(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.subtitle, size: 26),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.subtitle, fontSize: 10)),
        ]),
      );
 
  Widget _barraInferior() => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.3))),
        ),
        child: SafeArea(
          top: false,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(Icons.home_filled, 'HOME',
                () => Navigator.popUntil(context, (r) => r.isFirst)),
            _navItem(Icons.search, 'SEARCH', () {}),
            _navItem(Icons.person_outline, 'PROFILE', () {}),
            _navItem(Icons.camera_alt_outlined, 'CAMERA IA', () {}),
            _navItem(Icons.calendar_today_outlined, 'BOOK', _abrirCita),
          ]),
        ),
      );
 
  Widget _lista() => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _cargar,
        child: _barberos.isEmpty
            ? ListView(children: const [
                SizedBox(height: 80),
                Center(
                  child: Text('Aún no hay barberos disponibles.',
                      style: TextStyle(color: AppColors.subtitle)),
                ),
              ])
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _barberos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _tarjeta(_barberos[i]),
              ),
      );
 
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _encabezado(),
            Divider(color: AppColors.border.withValues(alpha: 0.6), indent: 16, endIndent: 16),
            Expanded(
              child: _cargando ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : _lista(),
            ),
          ]),
        ),
        bottomNavigationBar: _barraInferior(),
      );
}