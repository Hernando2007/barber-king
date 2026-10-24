part of '../../screens/admin/admin_usuarios_screen.dart';

extension _AdminUsuariosAcciones on _AdminUsuariosScreenState {
  Future<void> _abrirFormulario([Map<String, dynamic>? usuario]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUsuarioFormScreen(usuario: usuario),
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(Map<String, dynamic> usuario) async {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    final id = int.tryParse('${usuario['id']}') ?? 0;

    if (id == 0) return;

    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar usuario',
      message:
          '¿Seguro que deseas eliminar a ${nombre.isEmpty ? 'este usuario' : nombre}? '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar) return;

    var respuesta = await _admin.eliminarUsuario(id);

    if (!mounted) return;

    if (respuesta['statusCode'] == 409) {
      final detalles = respuesta['detalles'];
      var resumen = '';

      if (detalles is Map) {
        final partes = <String>[];
        void agregar(String etiqueta, dynamic valor) {
          final cantidad = int.tryParse('$valor') ?? 0;
          if (cantidad > 0) partes.add('$cantidad $etiqueta');
        }

        agregar('citas', detalles['citas']);
        agregar('reseñas', detalles['resenas']);
        agregar('mensajes', detalles['mensajes']);
        agregar('horarios', detalles['horarios']);
        resumen = partes.join(', ');
      }

      final forzar = await showConfirmDialog(
        context,
        title: 'El usuario tiene información asociada',
        message: resumen.isEmpty
            ? '${respuesta['message'] ?? 'No se puede eliminar el usuario.'}\n\n'
                  '¿Deseas eliminarlo junto con todos sus registros?'
            : '${respuesta['message'] ?? 'No se puede eliminar el usuario.'}\n\n'
                  'Registros asociados: $resumen.\n\n'
                  'Si continúas, se eliminarán también esas citas, reseñas, '
                  'mensajes y horarios.',
        confirmLabel: 'Eliminar todo',
        destructive: true,
      );

      if (!forzar) return;

      respuesta = await _admin.eliminarUsuario(id, forzar: true);

      if (!mounted) return;
    }

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Operación completada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }
}
