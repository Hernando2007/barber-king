import 'dart:async';

import 'package:geolocator/geolocator.dart';

class UbicacionException implements Exception {
  final String mensaje;

  const UbicacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

class PosicionUsuario {
  final double latitud;
  final double longitud;

  const PosicionUsuario({
    required this.latitud,
    required this.longitud,
  });
}

class UbicacionService {
  static const _ajustes = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 20),
  );

  Future<PosicionUsuario> obtenerPosicion() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionException(
        'Activa la ubicación (GPS) del dispositivo para continuar.',
      );
    }

    var permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever) {
      throw const UbicacionException(
        'El permiso de ubicación está bloqueado. Habilítalo en los ajustes.',
      );
    }

    if (permiso == LocationPermission.denied) {
      throw const UbicacionException(
        'Necesitamos tu ubicación para mostrarte barberos cercanos.',
      );
    }

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: _ajustes,
      );

      return PosicionUsuario(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      );
    } on TimeoutException {
      final ultima = await Geolocator.getLastKnownPosition();

      if (ultima != null) {
        return PosicionUsuario(
          latitud: ultima.latitude,
          longitud: ultima.longitude,
        );
      }

      throw const UbicacionException(
        'No pudimos obtener tu ubicación. Intenta al aire libre.',
      );
    }
  }
}
