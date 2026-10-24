import 'package:flutter/material.dart';

import 'colors.dart';

class AppFormat {
  AppFormat._();

  static const _months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _monthsLong = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const _weekdays = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  static DateTime? toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static String date(dynamic value) {
    final parsed = toDate(value);

    if (parsed == null) {
      return '-';
    }

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_months[parsed.month - 1]} ${parsed.year}';
  }

  static String dateLong(dynamic value) {
    final parsed = toDate(value);

    if (parsed == null) {
      return '-';
    }

    return '${_weekdays[parsed.weekday - 1]}, ${parsed.day} de '
        '${_monthsLong[parsed.month - 1]}';
  }

  static String time(dynamic value) {
    if (value == null) {
      return '-';
    }

    return value.toString().split(':').take(2).join(':');
  }

  static String money(dynamic value) {
    final number = num.tryParse('$value');

    if (number == null) {
      return '\$ 0';
    }

    final digits = number.round().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(digits[index]);
    }

    return '\$ $buffer';
  }

  static String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Buenos días';
    }

    if (hour < 19) {
      return 'Buenas tardes';
    }

    return 'Buenas noches';
  }

  static Color statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'confirmada':
      case 'completada':
      case 'activo':
      case 'activa':
        return AppColors.success;
      case 'cancelada':
      case 'inactivo':
      case 'inactiva':
        return AppColors.error;
      case 'pendiente':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  static String role(int? roleId) {
    switch (roleId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Barbero';
      case 3:
        return 'Cliente';
      default:
        return 'Usuario';
    }
  }

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
