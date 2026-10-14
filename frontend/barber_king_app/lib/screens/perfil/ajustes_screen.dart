import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../../widgets/perfil/editar_perfil_dialog.dart';
import '../chat/chat_ia_screen.dart';
import '../citas/citas_screen.dart';

class AjustesScreen extends StatefulWidget {
  final Map<String, dynamic> perfil;

  const AjustesScreen({super.key, required this.perfil});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _usuarios = UsuarioService();
  late Map<String, dynamic> _perfil = Map.of(widget.perfil);

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _ir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  Future<void> _editarCuenta() async {
    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditarPerfilDialog(
        nombres: '${_perfil['nombres'] ?? ''}',
        apellidos: '${_perfil['apellidos'] ?? ''}',
        telefono: '${_perfil['telefono'] ?? ''}',
      ),
    );
    if (datos == null) return;

    final r = await _usuarios.actualizarPerfil(datos);
    if (!mounted) return;
    if (r['success'] == true) setState(() => _perfil = {..._perfil, ...datos});
    _aviso(r['success'] == true ? 'Perfil actualizado.' : '${r['message']}');
  }

  Future<void> _ubicaciones() async {
    final lista = await BarberoService().obtenerBarberos();
    if (!mounted) return;
    final conDireccion = lista
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((b) => '${b['direccion'] ?? ''}'.trim().isNotEmpty)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: conDireccion.isEmpty
            ? [
                const Text(
                  'Aún no hay ubicaciones registradas.',
                  style: TextStyle(color: AppColors.subtitle),
                ),
              ]
            : [
                for (final b in conDireccion)
                  ListTile(
                    leading: const Icon(
                      Icons.place_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text('${b['direccion']}'),
                    subtitle: Text(nombreBarbero(b)),
                  ),
              ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await AuthService().cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Widget _opcion(
    IconData icono,
    String titulo,
    String detalle,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pronto = 'Próximamente.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: Text(
                    'AJUSTES',
                    textAlign: TextAlign.center,
                    style: tituloSerif(size: 22),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: FotoRed(
                  url: _perfil['foto']?.toString(),
                  ancho: 96,
                  alto: 96,
                  circular: true,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _usuarios.nombreCompleto(_perfil).toUpperCase(),
                style: tituloSerif(size: 18, color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                _usuarios.rolUsuario(_perfil),
                style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            _opcion(
              Icons.notifications_none,
              'Notificaciones',
              'Avisos de citas y novedades',
              () => _aviso(pronto),
            ),
            _opcion(
              Icons.history,
              'Historial de servicios',
              'Revisa tus cortes y servicios',
              () => _ir(const CitasScreen(historial: true)),
            ),
            _opcion(
              Icons.settings_outlined,
              'Configuración de cuenta',
              'Cambia tu nombre y teléfono',
              _editarCuenta,
            ),
            _opcion(
              Icons.support_agent,
              'Soporte y ayuda',
              'Chatea con el asistente de la barbería',
              () => _ir(const ChatIAScreen()),
            ),
            _opcion(
              Icons.place_outlined,
              'Ubicaciones de la barbería',
              'Direcciones de nuestros barberos',
              _ubicaciones,
            ),
            _opcion(
              Icons.description_outlined,
              'Términos y condiciones',
              'Políticas y uso de la app',
              () => _aviso(pronto),
            ),
            _opcion(
              Icons.logout,
              'Cerrar sesión',
              'Salir de tu cuenta',
              _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}
