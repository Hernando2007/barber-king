import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';

typedef _Mapa = Map<String, dynamic>;

class CatalogoEstilosScreen extends StatefulWidget {
  const CatalogoEstilosScreen({super.key});

  @override
  State<CatalogoEstilosScreen> createState() => _CatalogoEstilosScreenState();
}

class _CatalogoEstilosScreenState extends State<CatalogoEstilosScreen> {
  static const _categorias = ['Todos', 'Cortes', 'Barba'];
  static const _tiposCabello = ['Corto', 'Mediano', 'Largo', 'Rizado', 'Liso'];

  final TextEditingController _busqueda = TextEditingController();
  List<_Mapa> _servicios = [];
  _Mapa? _seleccionado;
  String _catActiva = 'Todos';
  String? _tipoCabello;
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

  Future<void> _cargar() async {
    try {
      final lista = await ServicioService().obtenerServicios();
      if (!mounted) return;
      setState(() {
        _servicios = lista
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((s) => s['estado'] != false)
            .toList();
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  bool _esBarba(_Mapa s) =>
      '${s['nombre']} ${s['descripcion']}'.toLowerCase().contains('barba');

  List<_Mapa> get _serviciosFiltrados {
    final q = _busqueda.text.trim().toLowerCase();
    return _servicios.where((s) {
      final coincideNombre = '${s['nombre']} ${s['descripcion']}'
          .toLowerCase()
          .contains(q);
      if (_catActiva == 'Cortes') return coincideNombre && !_esBarba(s);
      if (_catActiva == 'Barba') return coincideNombre && _esBarba(s);
      return coincideNombre;
    }).toList();
  }

  void _reservar() {
    if (_seleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, elige un estilo del catálogo.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearCitaScreen(
          servicioInicial: _seleccionado,
          observaciones:
              _tipoCabello == null ? null : 'Tipo de cabello: $_tipoCabello',
        ),
      ),
    );
  }

  Widget _tarjetaServicio(_Mapa s) {
    final activo = _seleccionado?['id'] == s['id'];
    final precio = num.tryParse('${s['precio']}') ?? 0;
    final duracion = s['duracion'] ?? 30;

    return GestureDetector(
      onTap: () => setState(() => _seleccionado = s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.border,
            width: activo ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FotoRed(
                url: s['imagen']?.toString(),
                ancho: 75,
                alto: 75,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s['nombre']}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s['descripcion'] ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${precioCOP(precio)} · $duracion min',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Radio<_Mapa>(
              value: s,
              groupValue: _seleccionado,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _seleccionado = val),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _serviciosFiltrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Título y Buscador
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  const Text(
                    'CATÁLOGO DE ESTILOS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _busqueda,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar servicio...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            // Chips de categorías
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categorias[i];
                  final sel = _catActiva == cat;
                  return ChoiceChip(
                    label: Text(cat.toUpperCase()),
                    selected: sel,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sel ? AppColors.black : Colors.white,
                    ),
                    onSelected: (_) => setState(() => _catActiva = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Lista principal de servicios ocupando el espacio de forma segura
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: lista.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'No se encontraron servicios.',
                                    style: TextStyle(color: AppColors.subtitle),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: lista.length,
                              itemBuilder: (_, i) => _tarjetaServicio(lista[i]),
                            ),
                    ),
            ),

            // Filtro horizontal inferior para tipo de cabello
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: AppColors.card,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Cabello: ',
                      style: TextStyle(color: AppColors.subtitle, fontSize: 11),
                    ),
                    for (final t in _tiposCabello)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(t),
                          selected: _tipoCabello == t,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: _tipoCabello == t ? AppColors.black : Colors.white,
                          ),
                          onSelected: (s) => setState(() => _tipoCabello = s ? t : null),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: _seleccionado == null ? null : _reservar,
          child: Text(
            _seleccionado == null
                ? 'SELECCIONA UN ESTILO'
                : 'RESERVAR ${_seleccionado!['nombre']}'.toUpperCase(),
          ),
        ),
      ),
    );
  }
}