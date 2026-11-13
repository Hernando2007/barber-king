import 'package:flutter_test/flutter_test.dart';

import 'package:barber_king_app/core/colors.dart';
import 'package:barber_king_app/core/formatters.dart';

void main() {
  group('AppFormat.money', () {
    test('separa los miles con punto', () {
      expect(AppFormat.money(20000), r'$ 20.000');
      expect(AppFormat.money(1500), r'$ 1.500');
      expect(AppFormat.money('350000'), r'$ 350.000');
    });

    test('redondea y devuelve cero cuando el dato no es número', () {
      expect(AppFormat.money(1500.6), r'$ 1.501');
      expect(AppFormat.money('gratis'), r'$ 0');
      expect(AppFormat.money(null), r'$ 0');
    });
  });

  group('AppFormat fechas y horas', () {
    test('date usa el formato corto en español', () {
      expect(AppFormat.date('2026-11-13'), '13 nov 2026');
      expect(AppFormat.date(null), '-');
      expect(AppFormat.date('no-es-fecha'), '-');
    });

    test('time se queda solo con horas y minutos', () {
      expect(AppFormat.time('14:30:00'), '14:30');
      expect(AppFormat.time('09:05:44'), '09:05');
      expect(AppFormat.time(null), '-');
    });

    test('relativeDay marca solo hoy y mañana', () {
      final hoy = DateTime.now();

      expect(AppFormat.relativeDay(hoy), 'Hoy');
      expect(
        AppFormat.relativeDay(hoy.add(const Duration(days: 1))),
        'Mañana',
      );
      expect(AppFormat.relativeDay(hoy.add(const Duration(days: 5))), '');
    });
  });

  group('AppFormat datos de perfil', () {
    test('initials toma la primera y la última letra', () {
      expect(AppFormat.initials('Ana María Pérez'), 'AP');
      expect(AppFormat.initials('  Luis  '), 'L');
      expect(AppFormat.initials('   '), '');
    });

    test('role traduce el identificador del usuario', () {
      expect(AppFormat.role(1), 'Administrador');
      expect(AppFormat.role(2), 'Barbero');
      expect(AppFormat.role(3), 'Cliente');
      expect(AppFormat.role(null), 'Usuario');
      expect(AppFormat.role(42), 'Usuario');
    });

    test('statusColor respeta los estados reales de las citas', () {
      expect(AppFormat.statusColor('Confirmada'), AppColors.success);
      expect(AppFormat.statusColor('Completada'), AppColors.success);
      expect(AppFormat.statusColor('Cancelada'), AppColors.error);
      expect(AppFormat.statusColor('Pendiente'), AppColors.warning);
      expect(AppFormat.statusColor('otro'), AppColors.info);
      expect(AppFormat.statusColor(null), AppColors.info);
    });
  });
}
