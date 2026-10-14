import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/chat_service.dart';
import '../../widgets/common/gold_cajas.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/crear_cita_screen.dart';
import 'chat_ia_screen.dart';

/// Pestaña "Cámara IA": foto del rostro -> POST /api/chat/recomendar-corte
class CameraAiScreen extends StatefulWidget {
  const CameraAiScreen({super.key});

  @override
  State<CameraAiScreen> createState() => _CameraAiScreenState();
}

class _CameraAiScreenState extends State<CameraAiScreen> {
  XFile? _foto;
  String? _sesionId;
  Map<String, dynamic>? _rec;
  bool _analizando = false;

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _elegir(ImageSource origen) async {
    final f = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (f != null) {
      setState(() {
        _foto = f;
        _rec = null;
      });
    }
  }

  Future<void> _analizar() async {
    setState(() => _analizando = true);
    try {
      final r = await ChatService().recomendarCorte(
        rutaFoto: _foto!.path,
        sesionId: _sesionId,
      );
      if (!mounted) return;
      setState(() {
        _sesionId = r['sesionId']?.toString();
        _rec = r['recomendacion'] is Map
            ? Map<String, dynamic>.from(r['recomendacion'])
            : null;
      });
      if (_rec == null) _aviso('La IA no devolvió una recomendación.');
    } catch (e) {
      if (mounted) _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => _analizando = false);
  }

  Widget _marco() {
    Widget esquina(IconData i, VoidCallback onTap) => IconButton(
      onPressed: onTap,
      icon: Icon(i, color: AppColors.primary),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.background.withValues(alpha: 0.7),
      ),
    );

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: _foto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.center_focus_strong_outlined,
                          color: AppColors.primary,
                          size: 64,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Apunta al rostro',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Image.file(File(_foto!.path), fit: BoxFit.cover),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: esquina(
                Icons.photo_library_outlined,
                () => _elegir(ImageSource.gallery),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: esquina(
                Icons.photo_camera_outlined,
                () => _elegir(ImageSource.camera),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultado() {
    final r = _rec!;
    final alternativas =
        (r['alternativas'] as List?)?.map((e) => '• $e').join('\n') ?? '';
    return CajaSeccion(
      'CORTE RECOMENDADO',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${r['corte_principal']}',
            style: tituloSerif(size: 18, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '${r['explicacion'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.subtitle),
          ),
          if (alternativas.isNotEmpty) ...[
            const SizedBox(height: 10),
            const EtiquetaCampo('Alternativas'),
            Text(alternativas, style: const TextStyle(fontSize: 12)),
          ],
          if ('${r['recomendacion_barbero'] ?? ''}'.isNotEmpty) ...[
            const SizedBox(height: 10),
            const EtiquetaCampo('Consejo del barbero'),
            Text(
              '${r['recomendacion_barbero']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  children: [
                    Text('CÁMARA IA', style: tituloSerif(size: 22)),
                    const Text(
                      '(Inteligencia Artificial)',
                      style: TextStyle(color: AppColors.subtitle, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Asistente de texto',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatIAScreen()),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _marco(),
          const SizedBox(height: 12),
          if (_rec != null)
            _resultado()
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text(
                    'La IA analizará tu rostro y te recomendará los cortes que mejor te quedan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtitle, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tu foto se sube para generar la recomendación y queda en tu historial con el asistente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (_rec == null)
            ElevatedButton(
              onPressed: _foto == null || _analizando ? null : _analizar,
              child: _analizando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.black,
                      ),
                    )
                  : const Text('ANALIZAR MI ROSTRO'),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrearCitaScreen(
                    observaciones:
                        'Corte sugerido por IA: ${_rec!['corte_principal']}',
                  ),
                ),
              ),
              child: const Text('RESERVAR ESTE CORTE'),
            ),
        ],
      ),
    );
  }
}
