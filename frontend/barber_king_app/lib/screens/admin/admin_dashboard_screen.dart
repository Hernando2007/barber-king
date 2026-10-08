import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  final _auth = AuthService();

  bool loading = true;
  String? error;
  Map<String, dynamic> data = {};
  int section = 0;

  final titles = ['Usuarios', 'Barberos', 'Citas', 'Servicios', 'Reseñas'];
  final icons = [
    Icons.people_outline,
    Icons.content_cut,
    Icons.calendar_month,
    Icons.design_services_outlined,
    Icons.star_outline,
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      data = await _service.dashboard();
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => loading = false);
  }

  int _n(dynamic value) => int.tryParse('$value') ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          section == 0 ? 'Panel administrativo' : titles[section - 1],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: _drawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(error!, textAlign: TextAlign.center),
              ),
            )
          : _content(),
    );
  }

  Drawer _drawer() => Drawer(
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: .15),
            child: Icon(Icons.content_cut, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          const Text(
            'BARBER KING',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Administrador',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(),
          _menu(Icons.dashboard_outlined, 'Dashboard', 0),
          _menu(Icons.people_outline, 'Usuarios', 1),
          _menu(Icons.content_cut, 'Barberos', 2),
          _menu(Icons.calendar_month, 'Citas', 3),
          _menu(Icons.design_services_outlined, 'Servicios', 4),
          _menu(Icons.star_outline, 'Reseñas', 5),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await _auth.cerrarSesion();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    ),
  );

  Widget _menu(IconData icon, String title, int index) => ListTile(
    selected: section == index,
    selectedColor: AppColors.primary,
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      setState(() => section = index);
    },
  );

  Widget _content() {
    if (section == 0) return _dashboard();

    final loaders = [
      _service.usuarios,
      _service.barberos,
      _service.citas,
      _service.servicios,
      _service.resenas,
    ];

    return _listPage(titles[section - 1], loaders[section - 1]);
  }

  Widget _dashboard() {
    final r = Map<String, dynamic>.from(data['resumen'] ?? {});
    final c = Map<String, dynamic>.from(data['citas'] ?? {});

    final cards = [
      ['Usuarios', _n(r['totalUsuarios']), Icons.people_outline],
      ['Barberos', _n(r['totalBarberos']), Icons.content_cut],
      ['Servicios', _n(r['totalServicios']), Icons.design_services],
      ['Citas', _n(r['totalCitas']), Icons.calendar_month],
      ['Reseñas', _n(r['totalResenas']), Icons.star_outline],
      ['Pendientes', _n(c['pendientes']), Icons.pending_actions],
    ];

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Resumen general',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestiona y supervisa Barber King',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (_, i) => _card(
              cards[i][0] as String,
              cards[i][1] as int,
              cards[i][2] as IconData,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Administración'),
              subtitle: const Text(
                'Usuarios, barberos, citas, servicios y reseñas.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, int value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary),
          Text(title),
          Text(
            '$value',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  Widget _listPage(String title, Future<List<dynamic>> Function() loader) =>
      FutureBuilder<List<dynamic>>(
        future: loader(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: ${items.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Card(child: ListTile(title: Text('No hay registros.'))),
                ...items.map((item) => _item(title, item)),
              ],
            ),
          );
        },
      );

  Widget _item(String type, dynamic item) {
    final id = item['id'];
    final title =
        item['nombre']?.toString() ??
        item['nombres']?.toString() ??
        item['especialidad']?.toString() ??
        'Registro #$id';

    final sub =
        item['correo']?.toString() ??
        item['estado']?.toString() ??
        item['verificacion_estado']?.toString() ??
        (item['calificacion'] != null
            ? 'Calificación: ${item['calificacion']}/5'
            : 'ID: $id');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(_icon(type), color: AppColors.primary),
        title: Text(title),
        subtitle: Text(sub),
        trailing: _actions(type, id),
      ),
    );
  }

  IconData _icon(String type) {
    final map = {
      'Usuarios': Icons.person_outline,
      'Barberos': Icons.content_cut,
      'Citas': Icons.calendar_today,
      'Servicios': Icons.design_services_outlined,
      'Reseñas': Icons.star_outline,
    };
    return map[type] ?? Icons.circle_outlined;
  }

  Widget? _actions(String type, dynamic id) {
    if (id == null || !['Barberos', 'Servicios', 'Reseñas'].contains(type)) {
      return null;
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () => _delete(type, id),
    );
  }

  Future<void> _delete(String type, dynamic id) async {
    try {
      if (type == 'Barberos') await _service.eliminarBarbero(id);
      if (type == 'Servicios') await _service.eliminarServicio(id);
      if (type == 'Reseñas') await _service.eliminarResena(id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
