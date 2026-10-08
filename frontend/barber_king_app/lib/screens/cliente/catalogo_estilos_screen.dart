import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_cajas.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';

typedef _Mapa = Map<String, dynamic>;

/// Pestaña "Reservar": catálogo de servicios por categoría + tipo de cabello.
class CatalogoEstilosScreen extends StatefulWidget {
  const CatalogoEstilosScreen({super.key});

  @override
  State<CatalogoEstilosScreen> createState() => _CatalogoEstilosScreenState();
}

class _CatalogoEstilosScreenState extends State<CatalogoEstilosScreen> {
  static const _tipos = ['Corto', 'Mediano', 'Largo', 'Liso', 'Ondulado', 'Rizado'];

  List<_Mapa> _servicios = [];
  _Mapa? _seleccionado;
  String? _tipo;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await ServicioService().obtenerServicios();
    if (!mounted) return;
    setState(() {
      _servicios = lista.map((e) => Map<String, dynamic>.from(e as Map)).where((s) => s['estado'] != false).toList();
      _cargando = false;
    });
  }

  bool _esBarba(_Mapa s) => '${s['nombre']} ${s['descripcion']}'.toLowerCase().contains('barba');

  void _reservar() {
    if (_seleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elige un estilo del catálogo.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearCitaScreen(
          servicioInicial: _seleccionado,
          observaciones: _tipo == null ? null : 'Tipo de cabello: $_tipo',
        ),
      ),
    );
  }

  Widget _carrusel(List<_Mapa> lista) {
    if (lista.isEmpty) {
      return const Text('Aún no hay estilos en esta categoría.', style: TextStyle(color: AppColors.subtitle, fontSize: 12));
    }
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = lista[i];
          final activo = _seleccionado?['id'] == s['id'];
          return GestureDetector(
            onTap: () => setState(() => _seleccionado = s),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: activo ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: FotoRed(url: s['imagen']?.toString(), ancho: 72, alto: 72),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 76,
                  child: Text('${s['nombre']}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: activo ? AppColors.primary : Colors.white70)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cortes = _servicios.where((s) => !_esBarba(s)).toList();
    final barba = _servicios.where(_esBarba).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const Center(child: IconoCirculo(Icons.content_cut, tam: 60)),
                    const SizedBox(height: 10),
                    Center(child: Text('CATÁLOGO DE ESTILOS', style: tituloSerif(size: 22))),
                    const SizedBox(height: 16),
                    CajaSeccion('CORTES DE CABELLO', _carrusel(cortes)),
                    CajaSeccion('CUIDADO DE BARBA', _carrusel(barba)),
                    const EtiquetaCampo('Tipo de cabello'),
                    DropdownButtonFormField<String>(
                      value: _tipo,
                      hint: const Text('Seleccionar...'),
                      dropdownColor: AppColors.card,
                      iconEnabledColor: AppColors.primary,
                      items: [for (final t in _tipos) DropdownMenuItem(value: t, child: Text(t))],
                      onChanged: (v) => setState(() => _tipo = v),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in _tipos)
                          ChoiceChip(
                            label: Text(t.toUpperCase()),
                            selected: _tipo == t,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _tipo = t),
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: AppColors.border),
                            labelStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _tipo == t ? AppColors.black : Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const EtiquetaCampo('Herramientas sugeridas'),
                    const Row(
                      children: [
                        Icon(Icons.content_cut, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Tijeras y navajas premium recomendadas.',
                              style: TextStyle(color: AppColors.subtitle, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _reservar, child: const Text('RESERVAR ESTILO SELECCIONADO')),
                  ],
                ),
              ),
      ),
    );
  }
}
