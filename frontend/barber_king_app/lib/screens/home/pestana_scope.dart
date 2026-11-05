import 'package:flutter/widgets.dart';

/// Expone la barra de pestañas a las pantallas que viven dentro de ella.
///
/// Una pantalla necesita saber si la ruta que va a abrir es una pestaña:
/// si lo es, debe cambiar de pestaña en vez de apilar una copia de sí misma.
class PestanaScope extends InheritedWidget {
  const PestanaScope({super.key, required this.irARuta, required super.child});

  /// Cambia a la pestaña dueño de [ruta]; devuelve false si ninguna lo es.
  final bool Function(String ruta) irARuta;

  static PestanaScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PestanaScope>();

  @override
  bool updateShouldNotify(PestanaScope oldWidget) =>
      irARuta != oldWidget.irARuta;
}
