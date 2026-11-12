part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoHomeHero extends StatelessWidget {
  final Map<String, dynamic>? cita;
  final int citasHoy;
  final int pendientes;
  final VoidCallback onVerCitas;

  const _BarberoHomeHero({
    required this.cita,
    required this.citasHoy,
    required this.pendientes,
    required this.onVerCitas,
  });

  @override
  Widget build(BuildContext context) {
    final cita = this.cita;
    final estado = cita?['estado']?.toString() ?? 'Pendiente';
    final cliente = cita?['usuarios'];
    final servicio = cita?['servicios'];
    final nombreCliente = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : 'Cliente';
    final nombreServicio = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';

    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: AppColors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AGENDA DE HOY',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tu jornada en Barber King',
                      style: TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (cita != null)
                StatusPill(
                  label: estado,
                  color: AppFormat.statusColor(estado),
                )
              else
                const StatusPill(
                  label: 'Libre',
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (cita == null) ...[
            const Text(
              'Sin citas para hoy',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aprovecha para revisar tu disponibilidad y mantener tu perfil al día.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormat.time(cita['hora']),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'próxima cita',
                    style: TextStyle(
                      color: AppColors.subtitle.withValues(alpha: .9),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$nombreCliente · $nombreServicio',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: .7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BarberoHomeHeroDato(
                    icon: Icons.today_rounded,
                    label: 'Hoy',
                    valor: '$citasHoy',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BarberoHomeHeroDato(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pendientes',
                    valor: '$pendientes',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BarberoHomeHeroDato(
                    icon: Icons.schedule_rounded,
                    label: 'Próxima',
                    valor: cita == null
                        ? 'Libre'
                        : AppFormat.time(cita['hora']),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onVerCitas,
              icon: const Icon(Icons.event_note_outlined, size: 18),
              label: const Text('GESTIONAR AGENDA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarberoHomeHeroDato extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _BarberoHomeHeroDato({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 8.5,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
