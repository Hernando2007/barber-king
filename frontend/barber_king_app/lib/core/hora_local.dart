/// Dice si una hora de la agenda ("14:30") del día elegido ya quedó atrás
/// según el reloj del teléfono. El servidor no puede decidirlo: él corre en UTC.
bool horaYaPaso(DateTime fecha, String hora, {DateTime? ahora}) {
  final partes = hora.split(':');
  if (partes.length < 2) return false;

  final horas = int.tryParse(partes[0]);
  final minutos = int.tryParse(partes[1]);
  if (horas == null || minutos == null) return false;

  final inicio = DateTime(
    fecha.year,
    fecha.month,
    fecha.day,
    horas,
    minutos,
  );

  return !inicio.isAfter(ahora ?? DateTime.now());
}
