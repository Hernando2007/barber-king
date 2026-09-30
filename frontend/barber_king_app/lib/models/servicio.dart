class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracion;
  final int tiempoDescanso;
  final String? imagen;
  final bool estado;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracion,
    required this.tiempoDescanso,
    this.imagen,
    required this.estado,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json["id"],
      nombre: json["nombre"] ?? "",
      descripcion: json["descripcion"] ?? "",
      precio: (json["precio"] as num).toDouble(),
      duracion: json["duracion"] ?? 0,
      tiempoDescanso: json["tiempo_descanso"] ?? 0,
      imagen: json["imagen"],
      estado: json["estado"] ?? true,
    );
  }
}