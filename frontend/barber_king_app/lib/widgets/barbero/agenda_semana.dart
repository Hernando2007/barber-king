part of '../../screens/barbero/agenda_screen.dart';

class _AgendaSemana extends StatelessWidget {
  final DateTime inicioSemana;
  final DateTime dia;
  final Map<DateTime, int> cargaPorDia;
  final ValueChanged<DateTime> onDia;
  final ValueChanged<int> onSemana;
  final VoidCallback onHoy;

  const _AgendaSemana({
    required this.inicioSemana,
    required this.dia,
    required this.cargaPorDia,
    required this.onDia,
    required this.onSemana,
    required this.onHoy,
  });

  static const _letras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final partes = AppFormat.date(dia).split(' ');
    final mes = '${partes[1]} ${partes[2]}';

    return Column(
      children: [
        Row(
          children: [
            Text(
              _capital(mes),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _mismoDia(dia, hoy) ? null : onHoy,
              child: const Text('Hoy'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton(
              tooltip: 'Semana anterior',
              onPressed: () => onSemana(-1),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.subtitle,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: _diaDeLaSemana(
                        inicioSemana.add(Duration(days: i)),
                        _letras[i],
                        hoy,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Semana siguiente',
              onPressed: () => onSemana(1),
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _diaDeLaSemana(DateTime fecha, String letra, DateTime hoy) {
    final seleccionado = _mismoDia(fecha, dia);
    final esHoy = _mismoDia(fecha, hoy);
    final reservas = cargaPorDia[fecha] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AppCard(
        onTap: () => onDia(fecha),
        padding: const EdgeInsets.symmetric(vertical: 10),
        radius: 15,
        gradient: seleccionado ? AppColors.goldGradient : null,
        color: seleccionado ? null : AppColors.surface,
        borderColor: seleccionado
            ? AppColors.primary
            : esHoy
            ? AppColors.primary.withValues(alpha: .55)
            : AppColors.border,
        child: Column(
          children: [
            Text(
              letra,
              style: TextStyle(
                color: seleccionado ? AppColors.black : AppColors.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${fecha.day}',
              style: TextStyle(
                color: seleccionado ? AppColors.black : AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reservas == 0
                    ? Colors.transparent
                    : seleccionado
                    ? AppColors.black
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}