part of '../../screens/perfil/perfil_screen.dart';

extension _PerfilAcciones on _PerfilScreenState {
  Future<void> _cambiarFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (file == null) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _subiendoFoto = true);

    final bytes = await file.readAsBytes();
    final respuesta = await _usuarios.subirFoto(bytes, filename: file.name);

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _subiendoFoto = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Foto actualizada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      final data = respuesta['data'];
      final foto = data is Map
          ? data['foto']?.toString()
          : data?.toString();

      if (foto != null) {
        await _auth.actualizarUsuarioLocal({'foto': foto});
      }

      await _cargar();
    }
  }

  Future<void> _subirDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    if (!mounted) return;

    final respuesta = await _usuarios.subirDiploma(
      bytes,
      filename: file.name,
    );

    if (!mounted) return;

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Documento actualizado.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  Future<void> _editarPerfil() async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (_) => _PerfilEditSheet(
        usuario: _usuario ?? {},
        esBarbero: _esBarbero,
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Deseas salir de tu cuenta?',
      confirmLabel: 'Salir',
      destructive: true,
    );

    if (!confirmar) return;

    await _auth.cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}
