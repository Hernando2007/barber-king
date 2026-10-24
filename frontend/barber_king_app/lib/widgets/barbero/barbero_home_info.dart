part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoHomeHero extends StatelessWidget {
  final Map<String, dynamic>? cita;
  final VoidCallback onVerCitas;

  const _BarberoHomeHero({required this.cita, required this.onVerCitas});

  @override
  Widget build(BuildContext context) {
    final cita = this.cita;

    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'AGENDA DE HOY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onVerCitas,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          if (cita == null) ...[
            const SizedBox(height: 8),
            const Text(
              'No tienes citas pendientes para hoy',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Aprovecha para revisar tu disponibilidad y mantener tu perfil al día.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              AppFormat.time(cita['hora']),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              () {
                final cliente = cita['usuarios'];
                final servicio = cita['servicios'];
                final nombreCliente = cliente is Map
                    ? '${cliente['nombres'] ?? ''} '
                          '${cliente['apellidos'] ?? ''}'.trim()
                    : 'Cliente';
                final nombreServicio = servicio is Map
                    ? servicio['nombre']?.toString() ?? 'Servicio'
                    : 'Servicio';
                return '$nombreCliente · $nombreServicio';
              }(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StatusPill(
                  label: cita['estado']?.toString() ?? 'Pendiente',
                  color: AppFormat.statusColor(
                    cita['estado']?.toString(),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onVerCitas,
                  child: const Text('Gestionar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BarberoDatosProfesionales extends StatelessWidget {
  final Map<String, dynamic> barbero;

  const _BarberoDatosProfesionales({required this.barbero});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Especialidad',
            value: barbero['especialidad']?.toString() ?? '-',
          ),
          InfoRow(
            icon: Icons.timeline_outlined,
            label: 'Experiencia',
            value: '${barbero['experiencia'] ?? 0} años',
          ),
          InfoRow(
            icon: Icons.verified_outlined,
            label: 'Documento profesional',
            value: barbero['diploma_url'] == null
                ? 'No adjuntado'
                : 'Adjuntado y registrado',
          ),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: barbero['direccion']?.toString() ?? '-',
          ),
        ],
      ),
    );
  }
}
