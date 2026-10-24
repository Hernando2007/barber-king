part of '../../screens/chat/chat_conversacion_screen.dart';

class _ChatConversacionLista extends StatelessWidget {
  final List<Map<String, dynamic>> mensajes;
  final ScrollController controller;

  const _ChatConversacionLista({
    required this.mensajes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return mensajes.isEmpty
        ? ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 90),
              const EmptyState(
                icon: Icons.waving_hand_outlined,
                title: 'Inicia la conversación',
                message:
                    'Envía un saludo para comenzar a coordinar tu próxima cita.',
              ),
            ],
          )
        : ListView.builder(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: mensajes.length,
            itemBuilder: (_, index) =>
                _ChatConversacionBurbuja(mensaje: mensajes[index]),
          );
  }
}

class _ChatConversacionBurbuja extends StatelessWidget {
  final Map<String, dynamic> mensaje;

  const _ChatConversacionBurbuja({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final esMio = mensaje['esMio'] == true;
    final texto = mensaje['mensaje']?.toString() ?? '';
    final imagen = ApiConfig.resolveMedia(
      mensaje['imagen_url']?.toString(),
    );
    final hora = mensaje['created_at'] == null
        ? ''
        : AppFormat.time(
            AppFormat.toDate(mensaje['created_at'])
                ?.toLocal()
                .toIso8601String()
                .split('T')
                .last,
          );

    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          color: esMio ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 16),
          ),
          border: esMio ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagen != null && imagen.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagen,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.subtitle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
            ],
            if (texto.isNotEmpty)
              Text(
                texto,
                style: TextStyle(
                  color: esMio ? AppColors.black : AppColors.white,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            if (hora.isNotEmpty) ...[
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  hora,
                  style: TextStyle(
                    color: esMio
                        ? AppColors.black.withValues(alpha: .55)
                        : AppColors.muted,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
