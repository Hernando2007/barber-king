import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/portafolio_service.dart';
import '../common/app_ui.dart';

/// Las fotos de trabajo que el barbero publicó. Se oculta entero cuando
/// no tiene ninguna, para no dejar un título colgando en el perfil.
class BarberoPortafolioPanel extends StatefulWidget {
  final int barberoId;

  const BarberoPortafolioPanel({super.key, required this.barberoId});

  @override
  State<BarberoPortafolioPanel> createState() => _BarberoPortafolioPanelState();
}

class _BarberoPortafolioPanelState extends State<BarberoPortafolioPanel> {
  final PortafolioService _portafolio = PortafolioService();

  List<Map<String, dynamic>> _fotos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(BarberoPortafolioPanel anterior) {
    super.didUpdateWidget(anterior);

    if (anterior.barberoId != widget.barberoId) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    final fotos = await _portafolio.obtenerDeBarbero(widget.barberoId);

    if (!mounted) return;

    setState(() {
      _fotos = fotos;
      _cargando = false;
    });
  }

  List<String> get _urls => _fotos
      .map((foto) => '${foto['url'] ?? ''}')
      .where((url) => url.isNotEmpty)
      .toList();

  void _ampliar(int indice) {
    final urls = _urls;

    if (urls.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            VisorFoto(urls: urls, inicial: indice.clamp(0, urls.length - 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 168,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_fotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Su trabajo',
          subtitle: 'Fotos reales de sus cortes.',
          icon: Icons.photo_camera_outlined,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _fotos.length > 12 ? 12 : _fotos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, indice) => _Miniatura(
              url: '${_fotos[indice]['url'] ?? ''}',
              onPressed: () => _ampliar(indice),
            ),
          ),
        ),
      ],
    );
  }
}

class _Miniatura extends StatelessWidget {
  final String url;
  final VoidCallback onPressed;

  const _Miniatura({required this.url, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Material(
        color: AppColors.card,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            width: 128,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(15),
            ),
            child: url.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.muted,
                    ),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.muted,
                      ),
                    ),
                    loadingBuilder: (_, child, avance) => avance == null
                        ? child
                        : Container(
                            color: AppColors.surface,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
