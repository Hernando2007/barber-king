import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';
import 'vip_screen.dart';

typedef _Mapa = Map<String, dynamic>;

class InicioTab extends StatefulWidget {
  final ValueChanged<int> onIrATab;

  const InicioTab({super.key, required this.onIrATab});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  final _busqueda = TextEditingController();
  List<_Mapa> _barberos = [];
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

  Future<void> _cargar() async {
    final r = await Future.wait([
      BarberoService().obtenerBarberos(),
      ServicioService().obtenerServicios(),
    ]);
    if (!mounted) return;
    _Mapa mapa(e) => Map<String, dynamic>.from(e as Map);
    setState(() {
      _barberos = r[0].map(mapa).toList();
      _servicios = r[1].map(mapa).where((s) => s['estado'] != false).toList();
      _cargando = false;
    });
  }

  String get _q => _busqueda.text.trim().toLowerCase();

  void _reservar({int? barberoId, _Mapa? servicio}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CrearCitaScreen(
        barberoInicialId: barberoId,
        servicioInicial: servicio == null
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(servicio),
      ),
    ),
  );

  Widget _accion(
    IconData icono,
    String texto,
    VoidCallback onTap, {
    bool lleno = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lleno ? AppColors.primary : AppColors.card,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(
              icono,
              color: lleno ? AppColors.black : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: TextStyle(
              color: lleno ? AppColors.primary : Colors.white,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(List<Widget> hijos, String vacio) {
    if (hijos.isEmpty) {
      return Text(
        vacio,
        style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hijos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => hijos[i],
      ),
    );
  }

  Widget _tarjeta({
    required String? foto,
    required String titulo,
    required Widget pie,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 108,
        child: Column(
          children: [
            FotoRed(url: foto, ancho: 108, alto: 128),
            const SizedBox(height: 6),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            pie,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barberos = _barberos
        .where((b) => nombreBarbero(b).toLowerCase().contains(_q))
        .toList();
    final servicios = _servicios
        .where((s) => '${s['nombre']}'.toLowerCase().contains(_q))
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          children: [
            Center(child: Text('BARBER KING', style: tituloSerif(size: 28))),
            const SizedBox(height: 14),
            CampoBusqueda(
              controller: _busqueda,
              hint: 'Buscar...',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _accion(Icons.content_cut, 'CORTES', () => widget.onIrATab(4)),
                _accion(
                  Icons.person_outline,
                  'BARBEROS',
                  () => widget.onIrATab(1),
                ),
                _accion(
                  Icons.workspace_premium_outlined,
                  'VIP',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VipScreen()),
                  ),
                  lleno: true,
                ),
              ],
            ),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              TituloSeccion('BARBEROS', onTap: () => widget.onIrATab(1)),
              _fila([
                for (final b in barberos.take(10))
                  _tarjeta(
                    foto: fotoBarbero(b),
                    titulo: nombreBarbero(b),
                    pie: Estrellas(
                      valor:
                          (b['calificacion_promedio'] as num?)?.toDouble() ?? 0,
                    ),
                    onTap: () =>
                        _reservar(barberoId: int.tryParse('${b['id']}')),
                  ),
              ], 'No hay barberos para mostrar.'),
              TituloSeccion('CORTES', onTap: () => widget.onIrATab(4)),
              _fila([
                for (final s in servicios.take(10))
                  _tarjeta(
                    foto: s['imagen']?.toString(),
                    titulo: '${s['nombre']}',
                    pie: Text(
                      precioCOP(num.tryParse('${s['precio']}') ?? 0),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => _reservar(servicio: s),
                  ),
              ], 'No hay servicios para mostrar.'),
            ],
          ],
        ),
      ),
    );
  }
}
