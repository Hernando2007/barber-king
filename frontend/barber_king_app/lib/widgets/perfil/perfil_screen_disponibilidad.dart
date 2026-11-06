// ignore_for_file: invalid_use_of_protected_member

part of '../../screens/perfil/perfil_screen.dart';

extension _PerfilDisponibilidad on _PerfilScreenState {
  Future<bool> _cambiarDisponibilidad(bool activo) async {
    final respuesta = await _usuarios.actualizarPerfil({'disponible': activo});

    if (!mounted) return false;

    final ok = respuesta['success'] == true;

    showAppSnack(
      context,
      ok
          ? (activo
                ? 'Estás activo. Los clientes ya pueden reservarte.'
                : 'Estás inactivo. No recibirás nuevas reservas.')
          : respuesta['message']?.toString() ??
                'No se pudo cambiar tu estado.',
      error: !ok,
    );

    if (ok) {
      final remoto = await _usuarios.obtenerPerfilActual();

      if (remoto != null && mounted) {
        setState(() => _usuario = remoto);
      }
    }

    return ok;
  }
}

/// Interruptor de un toque: el barbero decide si aparece activo o inactivo.
/// Al estar inactivo no ofrece horas y el cliente no puede reservarlo.
class _PerfilDisponibilidadCard extends StatefulWidget {
  final bool disponible;
  final Future<bool> Function(bool) onCambiar;

  const _PerfilDisponibilidadCard({
    required this.disponible,
    required this.onCambiar,
  });

  @override
  State<_PerfilDisponibilidadCard> createState() =>
      _PerfilDisponibilidadCardState();
}

class _PerfilDisponibilidadCardState extends State<_PerfilDisponibilidadCard> {
  late bool _valor = widget.disponible;
  bool _cargando = false;

  @override
  void didUpdateWidget(covariant _PerfilDisponibilidadCard old) {
    super.didUpdateWidget(old);

    if (!_cargando && old.disponible != widget.disponible) {
      _valor = widget.disponible;
    }
  }

  Future<void> _alternar(bool nuevo) async {
    setState(() {
      _valor = nuevo;
      _cargando = true;
    });

    final ok = await widget.onCambiar(nuevo);

    if (!mounted) return;

    setState(() {
      _cargando = false;
      if (!ok) _valor = !nuevo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _valor,
        onChanged: _cargando ? null : _alternar,
        activeThumbColor: AppColors.success,
        title: Text(
          _valor ? 'Estás activo' : 'Estás inactivo',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          _valor
              ? 'Los clientes ven tu perfil y pueden reservarte.'
              : 'No apareces disponible y no recibirás reservas.',
          style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
        ),
        secondary: _cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _valor ? Icons.storefront : Icons.storefront_outlined,
                color: _valor ? AppColors.success : AppColors.error,
              ),
      ),
    );
  }
}