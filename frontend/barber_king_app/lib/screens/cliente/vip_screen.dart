import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';

typedef _Mapa = Map<String, dynamic>;

/// Tratamientos VIP: los servicios de mayor precio del catálogo.
class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final _busqueda = TextEditingController();
  List<_Mapa> _servicios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  double _precio(_Mapa s) => double.tryParse('${s['precio']}') ?? 0;

  Future<void> _cargar() async {
    final lista = await ServicioService().obtenerServicios();
    if (!mounted) return;
    final servicios = lista
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((s) => s['estado'] != false)
        .toList()
      ..sort((a, b) => _precio(b).compareTo(_precio(a)));
    setState(() {
      _servicios = servicios.take(8).toList();
      _cargando = false;
    });
  }

  Widget _tarjeta(_Mapa s, {required bool grande}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FotoRed(url: s['imagen']?.toString(), ancho: double.infinity, alto: grande ? 150 : 90),
          const SizedBox(height: 10),
          Text('${s['nombre']}'.toUpperCase(), style: tituloSerif(size: grande ? 15 : 12)),
          const SizedBox(height: 4),
          Text('${s['descripcion'] ?? ''}',
              maxLines: grande ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.subtitle, fontSize: 11)),
          const SizedBox(height: 8),
          Text(precioCOP(_precio(s)),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CrearCitaScreen(servicioInicial: s)),
            ),
            child: const Text('RESERVAR AHORA', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _busqueda.text.trim().toLowerCase();
    final lista = _servicios.where((s) => '${s['nombre']} ${s['descripcion']}'.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
                Expanded(child: Text('BARBER KING', textAlign: TextAlign.center, style: tituloSerif(size: 26))),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 10),
            CampoBusqueda(controller: _busqueda, hint: 'BÚSQUEDA VIP', onChanged: (_) => setState(() {})),
            const SizedBox(height: 18),
            if (_cargando)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (lista.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('No hay tratamientos VIP para mostrar.', style: TextStyle(color: AppColors.subtitle))),
              )
            else ...[
              if (lista.length >= 2)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _tarjeta(lista[0], grande: false)),
                    const SizedBox(width: 12),
                    Expanded(child: _tarjeta(lista[1], grande: false)),
                  ],
                )
              else
                _tarjeta(lista[0], grande: true),
              for (final s in lista.skip(2))
                Padding(padding: const EdgeInsets.only(top: 12), child: _tarjeta(s, grande: true)),
            ],
          ],
        ),
      ),
    );
  }
}
