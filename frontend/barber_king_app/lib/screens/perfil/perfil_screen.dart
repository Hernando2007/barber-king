import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/usuario_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _auth = AuthService();
  final _usuarios = UsuarioService();

  Map<String, dynamic>? usuario;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final remoto = await _usuarios.obtenerPerfilActual();
    final local = await _auth.obtenerUsuario();

    if (!mounted) return;

    setState(() {
      usuario = remoto ?? local;
      cargando = false;
    });
  }

  String _rol() {
    final id = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
    return id == 2 ? 'Barbero' : 'Cliente';
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final esBarbero = _rol() == 'Barbero';
    final barbero = usuario?['barbero'];
    final nombre =
        '${usuario?['nombres'] ?? ''} ${usuario?['apellidos'] ?? ''}'.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(esBarbero ? 'Perfil profesional' : 'Mi perfil')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _avatar(nombre, esBarbero),
            const SizedBox(height: 22),
            const _Title('Información personal'),
            const SizedBox(height: 12),
            _info(Icons.person_outline, 'Nombre', nombre),
            _info(
              Icons.email_outlined,
              'Correo',
              usuario?['correo']?.toString() ?? '-',
            ),
            _info(
              Icons.phone_outlined,
              'Teléfono',
              usuario?['telefono']?.toString() ?? '-',
            ),
            if (esBarbero && barbero is Map) ...[
              const SizedBox(height: 22),
              const _Title('Información profesional'),
              const SizedBox(height: 12),
              _info(
                Icons.workspace_premium_outlined,
                'Especialidad',
                barbero['especialidad']?.toString() ?? '-',
              ),
              _info(
                Icons.description_outlined,
                'Documento profesional',
                barbero['diploma_url'] == null
                    ? 'No adjuntado'
                    : 'Documento adjuntado',
              ),
              _info(
                Icons.verified_outlined,
                'Verificación',
                barbero['verificacion_estado']?.toString() ?? 'pendiente',
              ),
            ] else ...[
              const SizedBox(height: 22),
              const _Title('Preferencias del cliente'),
              const SizedBox(height: 12),
              _info(
                Icons.notifications_none_outlined,
                'Notificaciones',
                'Configurables desde tu cuenta',
              ),
            ],
            const SizedBox(height: 25),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout_outlined),
                label: const Text('CERRAR SESIÓN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String nombre, bool esBarbero) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surface,
            child: Icon(
              esBarbero ? Icons.content_cut : Icons.person,
              color: AppColors.primary,
              size: 50,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nombre.isEmpty ? 'Usuario' : nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            esBarbero ? 'Perfil profesional' : 'Cliente',
            style: const TextStyle(color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await _auth.cerrarSesion();
    if (!context.mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
