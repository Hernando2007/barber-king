import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_avatar.dart';

/// Un destino del cajón de navegación del administrador.
class DestinoCajon {
  const DestinoCajon({
    required this.etiqueta,
    required this.detalle,
    required this.icono,
    required this.onTap,
    this.contador = 0,
    this.actual = false,
    this.peligro = false,
  });

  final String etiqueta;
  final String detalle;
  final IconData icono;

  /// Se invoca después de cerrar el cajón, así que ya se puede navegar.
  final VoidCallback onTap;

  /// Píldora roja con el total cuando supera cero (avisos pendientes).
  final int contador;

  /// Destino en el que se está parado: se resalta en dorado.
  final bool actual;

  /// Se pinta en rojo: la salida del panel.
  final bool peligro;
}

/// Cajón de navegación del panel administrativo.
///
/// El admin trabaja desde una consola con varios destinos y el panel es un
/// scroll largo: aquí quedan siempre a un toque, sin tener que subir a
/// buscarlos. Perfil y cerrar sesión van al pie para que tampoco se pierdan
/// con el scroll del encabezado.
class AdminCajon extends StatelessWidget {
  const AdminCajon({
    super.key,
    required this.usuario,
    required this.destinos,
    required this.onPerfil,
    required this.onSalir,
  });

  /// Datos de la cuenta para la cabecera (nombres, apellidos, foto, email).
  final Map<String, dynamic> usuario;

  /// Destinos del negocio. El orden en que se pasan es el que se pinta.
  final List<DestinoCajon> destinos;

  final VoidCallback onPerfil;
  final VoidCallback onSalir;

  /// Cierra el cajón y recién entonces ejecuta la acción del destino.
  ///
  /// El cajón no es una ruta: es una entrada de historial local de la ruta
  /// actual, así que este pop solo lo cierra y la pantalla de atrás sigue
  /// montada (Route.didPop con historial local no saca la ruta).
  void _abrir(BuildContext context, DestinoCajon destino) {
    Navigator.pop(context);
    destino.onTap();
  }

  String get _nombre {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Administrador' : nombre;
  }

  DestinoCajon get _perfil => DestinoCajon(
        etiqueta: 'Mi perfil',
        detalle: 'Tu cuenta y preferencias',
        icono: Icons.person_outline_rounded,
        onTap: onPerfil,
      );

  DestinoCajon get _salir => DestinoCajon(
        etiqueta: 'Cerrar sesión',
        detalle: 'Sale del panel administrativo',
        icono: Icons.logout_outlined,
        onTap: onSalir,
        peligro: true,
      );

  @override
  Widget build(BuildContext context) {
    final nombre = _nombre;
    final email = '${usuario['email'] ?? ''}'.trim();
    final foto = usuario['foto']?.toString();

    return Drawer(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(22)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cabecera(nombre: nombre, email: email, fotoUrl: foto),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                children: [
                  for (final destino in destinos)
                    _ItemCajon(
                      destino: destino,
                      onTap: () => _abrir(context, destino),
                    ),
                  const Divider(indent: 14, endIndent: 14, height: 28),
                  _ItemCajon(
                    destino: _perfil,
                    onTap: () => _abrir(context, _perfil),
                  ),
                  _ItemCajon(
                    destino: _salir,
                    onTap: () => _abrir(context, _salir),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.nombre,
    required this.email,
    required this.fotoUrl,
  });

  final String nombre;
  final String email;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          AppAvatar(name: nombre, photoUrl: fotoUrl, radius: 26),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CONSOLA DE ADMINISTRACIÓN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCajon extends StatelessWidget {
  const _ItemCajon({required this.destino, required this.onTap});

  final DestinoCajon destino;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = destino.peligro ? AppColors.error : AppColors.primary;
    final fondo = destino.peligro
        ? AppColors.error.withValues(alpha: .12)
        : destino.actual
            ? AppColors.primary.withValues(alpha: .2)
            : AppColors.primary.withValues(alpha: .12);
    final texto = destino.peligro
        ? AppColors.error
        : destino.actual
            ? AppColors.primary
            : AppColors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: fondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(destino.icono, color: color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destino.etiqueta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: texto,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destino.detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (destino.contador > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    destino.contador > 9 ? '9+' : '${destino.contador}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
