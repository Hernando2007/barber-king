part of '../../screens/admin/admin_revision_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _AdminRevisionLogica on _AdminRevisionScreenState {
  Future<void> _cargar() async {
    final pendientes = await _revision.pendientes();

    if (!mounted) return;

    setState(() {
      _pendientes = pendientes ?? [];
      _cargando = false;
    });

    if (pendientes == null) {
      showAppSnack(context, 'No se pudo cargar la bandeja.', error: true);
    }
  }

  Future<void> _aprobar(Map<String, dynamic> barbero) async {
    final nombre = barbero['nombre']?.toString().trim() ?? 'Barbero';

    final confirmado = await showConfirmDialog(
      context,
      title: 'Verificar a $nombre',
      message: 'Su perfil mostrará el sello de verificado a los clientes.',
      confirmLabel: 'Aprobar',
    );

    if (!confirmado) return;

    await _decidir(barbero, 'aprobado');
  }

  Future<void> _rechazar(Map<String, dynamic> barbero) async {
    final nombre = barbero['nombre']?.toString().trim() ?? 'Barbero';

    await _mostrarRechazo(
      context,
      nombre,
      (nota) => _decidir(barbero, 'rechazado', nota: nota),
    );
  }

  Future<void> _decidir(
    Map<String, dynamic> barbero,
    String estado, {
    String? nota,
  }) async {
    final id = int.tryParse('${barbero['barbero_id']}');

    if (id == null) return;

    setState(() => _ocupado = id);

    final respuesta = await _revision.decidir(id, estado, nota: nota);

    if (!mounted) return;

    setState(() => _ocupado = null);

    final exito = respuesta['success'] == true;

    showAppSnack(
      context,
      respuesta['message']?.toString() ??
          (exito
              ? 'Decisión registrada.'
              : 'No se pudo registrar la decisión.'),
      error: !exito,
    );

    if (exito) {
      await _cargar();
    }
  }

  void _abrirDocumento(Map<String, dynamic> barbero) {
    final diploma = barbero['diploma'];

    if (diploma is! Map) return;

    final url = ApiConfig.resolveMedia(diploma['url']?.toString());

    if (url == null) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VisorFoto(urls: [url])));
  }
}
