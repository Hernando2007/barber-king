part of '../../screens/barbero/mis_fotos_screen.dart';

/// La rejilla: primero lo publicado, después las que están por subirse.
class _Cuadricula extends StatelessWidget {
  const _Cuadricula({
    required this.fotos,
    required this.pendientes,
    required this.onBorrar,
    required this.onQuitar,
    required this.onAmpliar,
  });

  final List<Map<String, dynamic>> fotos;
  final List<XFile> pendientes;
  final ValueChanged<Map<String, dynamic>> onBorrar;
  final ValueChanged<XFile> onQuitar;
  final ValueChanged<int> onAmpliar;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      children: [
        for (var i = 0; i < fotos.length; i++)
          _CuadroPublicada(
            foto: fotos[i],
            onBorrar: onBorrar,
            onAmpliar: () => onAmpliar(i),
          ),
        for (final archivo in pendientes)
          _CuadroPendiente(archivo: archivo, onQuitar: onQuitar),
        if (fotos.isEmpty && pendientes.isEmpty) const _CuadroInvitacion(),
      ],
    );
  }
}

class _CuadroPublicada extends StatelessWidget {
  const _CuadroPublicada({
    required this.foto,
    required this.onBorrar,
    required this.onAmpliar,
  });

  final Map<String, dynamic> foto;
  final ValueChanged<Map<String, dynamic>> onBorrar;
  final VoidCallback onAmpliar;

  @override
  Widget build(BuildContext context) {
    final url = foto['url']?.toString() ?? '';

    return _Marco(
      onPresionar: url.isEmpty ? null : onAmpliar,
      hijo: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.muted,
            ),
            loadingBuilder: (_, child, avance) =>
                avance == null ? child : const _CargandoCuadro(),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _BotonEsquina(
              icon: Icons.delete_outline_rounded,
              color: AppColors.error,
              tooltip: 'Borrar foto',
              onPressed: () => onBorrar(foto),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuadroPendiente extends StatelessWidget {
  const _CuadroPendiente({required this.archivo, required this.onQuitar});

  final XFile archivo;
  final ValueChanged<XFile> onQuitar;

  @override
  Widget build(BuildContext context) {
    return _Marco(
      borde: AppColors.primary,
      hijo: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(archivo.path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.broken_image_outlined, color: AppColors.muted),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: const _Pill(texto: 'NUEVA', color: AppColors.primary),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _BotonEsquina(
              icon: Icons.close_rounded,
              color: AppColors.white,
              tooltip: 'Quitar de la selección',
              onPressed: () => onQuitar(archivo),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuadroInvitacion extends StatelessWidget {
  const _CuadroInvitacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.4),
      ),
      padding: const EdgeInsets.all(14),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 26, color: AppColors.primary),
          SizedBox(height: 10),
          Text(
            'Aún no has subido fotos.\nToca Agregar fotos y muestra tu mejor '
            'trabajo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}
