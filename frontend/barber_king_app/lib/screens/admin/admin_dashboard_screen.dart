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

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() { loading = true; error = null; });
    try {
      data = await _service.dashboard();
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  int n(dynamic value) => int.tryParse('$value') ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Panel administrativo'),
        actions: [IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh))],
      ),
      drawer: _drawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!, textAlign: TextAlign.center)))
              : _content(),
    );
  }

  Drawer _drawer() => Drawer(
    child: SafeArea(
      child: Column(children: [
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
          title: Text('Barber King', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Administrador'),
        ),
        const Divider(),
        _menu(Icons.dashboard, 'Dashboard', 0),
        _menu(Icons.people, 'Usuarios', 1),
        _menu(Icons.content_cut, 'Barberos', 2),
        _menu(Icons.calendar_month, 'Citas', 3),
        _menu(Icons.design_services, 'Servicios', 4),
        _menu(Icons.star, 'Reseñas', 5),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          onTap: () async {
            await _auth.cerrarSesion();
            if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
          },
        ),
      ]),
    ),
  );

  Widget _menu(IconData icon, String title, int index) => ListTile(
    selected: section == index,
    leading: Icon(icon),
    title: Text(title),
    onTap: () { Navigator.pop(context); setState(() => section = index); },
  );

  Widget _content() {
    if (section == 0) return _dashboard();
    final loaders = [_service.usuarios, _service.barberos, _service.citas, _service.servicios, _service.resenas];
    final titles = ['Usuarios', 'Barberos', 'Citas', 'Servicios', 'Reseñas'];
    return _listPage(titles[section - 1], loaders[section - 1]);
  }

  Widget _dashboard() {
    final r = Map<String, dynamic>.from(data['resumen'] ?? {});
    final c = Map<String, dynamic>.from(data['citas'] ?? {});
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Resumen general', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
          children: [
            _card('Usuarios', n(r['totalUsuarios']), Icons.people),
            _card('Barberos', n(r['totalBarberos']), Icons.content_cut),
            _card('Servicios', n(r['totalServicios']), Icons.design_services),
            _card('Citas', n(r['totalCitas']), Icons.calendar_month),
            _card('Reseñas', n(r['totalResenas']), Icons.star),
            _card('Pendientes', n(c['pendientes']), Icons.pending_actions),
          ],
        ),
        const SizedBox(height: 20),
        Card(child: ListTile(
          leading: const Icon(Icons.verified_user),
          title: const Text('Administración'),
          subtitle: const Text('Gestiona usuarios, barberos, citas, servicios y reseñas desde el menú.'),
        )),
      ]),
    );
  }

  Widget _card(String title, int value, IconData icon) => Card(
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: AppColors.primary),
      Text(title),
      Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    ])),
  );

  Widget _listPage(String title, Future<List<dynamic>> Function() loader) => FutureBuilder<List<dynamic>>(
    future: loader(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
      final items = snapshot.data ?? [];
      return RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Total: ${items.length}'),
          const SizedBox(height: 8),
          if (items.isEmpty) const Card(child: ListTile(title: Text('No hay registros.'))),
          ...items.map((item) => _item(title, item)),
        ]),
      );
    },
  );

  Widget _item(String type, dynamic item) {
    final id = item['id'];
    String title = item['nombre']?.toString() ?? item['nombres']?.toString() ?? item['especialidad']?.toString() ?? 'Registro #$id';
    String sub = item['correo']?.toString() ?? item['estado']?.toString() ?? item['verificacion_estado']?.toString() ?? (item['calificacion'] != null ? 'Calificación: ${item['calificacion']}/5' : 'ID: $id');
    return Card(child: ListTile(leading: Icon(_icon(type)), title: Text(title), subtitle: Text(sub), trailing: _actions(type, id)));
  }

  IconData _icon(String type) {
    switch (type) {
      case 'Usuarios': return Icons.person;
      case 'Barberos': return Icons.content_cut;
      case 'Citas': return Icons.calendar_today;
      case 'Servicios': return Icons.design_services;
      default: return Icons.star;
    }
  }

  Widget? _actions(String type, dynamic id) {
    if (id == null) return null;
    if (type == 'Barberos' || type == 'Servicios' || type == 'Reseñas') {
      return IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(type, id));
    }
    return null;
  }

  Future<void> _delete(String type, dynamic id) async {
    try {
      if (type == 'Barberos') await _service.eliminarBarbero(id);
      if (type == 'Servicios') await _service.eliminarServicio(id);
      if (type == 'Reseñas') await _service.eliminarResena(id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
