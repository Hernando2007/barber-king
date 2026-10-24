part of '../../screens/perfil/perfil_screen.dart';

extension _PerfilPassword on _PerfilScreenState {
  Future<void> _cambiarPassword() async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmar = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var procesando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> guardar() async {
            if (!formKey.currentState!.validate()) return;

            if (nueva.text != confirmar.text) {
              showAppSnack(
                context,
                'Las contraseñas nuevas no coinciden.',
                error: true,
              );
              return;
            }

            setSheetState(() => procesando = true);

            final respuesta = await _usuarios.actualizarPerfil({
              'password_actual': actual.text,
              'password_nueva': nueva.text,
            });

            if (!sheetContext.mounted) return;

            setSheetState(() => procesando = false);

            showAppSnack(
              sheetContext,
              respuesta['message']?.toString() ??
                  'Contraseña actualizada.',
              error: respuesta['success'] != true,
            );

            if (respuesta['success'] == true) {
              Navigator.pop(sheetContext);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: actual,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: _requerido,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nueva,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mínimo 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmar,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: _requerido,
                  ),
                  const SizedBox(height: 22),
                  PrimaryGradientButton(
                    label: 'ACTUALIZAR CONTRASEÑA',
                    icon: Icons.save_outlined,
                    loading: procesando,
                    onPressed: procesando ? null : guardar,
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
