part of '../../screens/perfil/perfil_screen.dart';

extension _PerfilCuenta on _PerfilScreenState {
  Future<void> _eliminarCuenta() async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar cuenta',
      message:
          'Se borrarán tu perfil, tus citas, reseñas, mensajes y demás datos '
          'asociados. Esta acción es permanente y no se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar || !mounted) return;

    final clave = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var procesando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> eliminar() async {
            if (!formKey.currentState!.validate()) return;

            setSheetState(() => procesando = true);

            final texto = clave.text.trim();
            final respuesta = await _usuarios.eliminarCuenta(
              password: texto,
              confirmacion: texto,
            );

            if (!mounted) return;
            if (!sheetContext.mounted) return;

            if (respuesta['success'] != true) {
              setSheetState(() => procesando = false);
              showAppSnack(
                context,
                respuesta['message']?.toString() ??
                    'No se pudo eliminar la cuenta.',
                error: true,
              );
              return;
            }

            Navigator.pop(sheetContext);
            await _auth.cerrarSesion();

            if (!mounted) return;

            showAppSnack(
              context,
              'Tu cuenta y tus datos fueron eliminados.',
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Confirma la eliminación',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escribe tu contraseña para continuar. Si entraste con '
                    'Google, escribe ELIMINAR.',
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: clave,
                    obscureText: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Contraseña o ELIMINAR',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: procesando ? null : eliminar,
                    icon: procesando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever_outlined),
                    label: Text(
                      procesando ? 'Eliminando...' : 'ELIMINAR CUENTA',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(48, 52),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
