part of '../../screens/servicios/servicios_screen.dart';

extension _ServiciosAcciones on _ServiciosScreenState {
  Future<void> _abrirFormulario([Map<String, dynamic>? servicio]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioFormScreen(servicio: servicio),
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(Map<String, dynamic> servicio) async {
    final id = int.tryParse('${servicio['id']}') ?? 0;
    if (id == 0) return;

    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar servicio',
      message:
          '¿Deseas eliminar "${servicio['nombre'] ?? 'este servicio'}"? '
          'Si tiene citas asociadas se pedirá una confirmación adicional.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar) return;

    var respuesta = await _service.eliminarServicio(id);

    if (!mounted) return;

    if (respuesta['statusCode'] == 409) {
      final detalles = respuesta['detalles'];
      final citas = detalles is Map ? int.tryParse('${detalles['citas']}') : null;

      final forzar = await showConfirmDialog(
        context,
        title: 'Servicio con citas asociadas',
        message:
            '${respuesta['message'] ?? 'No se puede eliminar el servicio.'}\n\n'
            '${citas != null && citas > 0 ? 'Tiene $citas cita(s) asociada(s).' : ''} '
            'Si continúas, se eliminarán también esas citas.',
        confirmLabel: 'Eliminar todo',
        destructive: true,
      );

      if (!forzar) return;

      respuesta = await _service.eliminarServicio(id, forzar: true);

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
