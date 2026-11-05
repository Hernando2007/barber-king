/// Interruptores de funciones que aún no salen a la calle. Apagarlas deja el
/// código en su sitio, listo para volver a encenderlo sin tocar pantallas.
class Funcionalidades {
  Funcionalidades._();

  /// El chat libre cliente-barbero está fuera del flujo principal: las
  /// solicitudes de un toque lo sustituyen.
  static const bool chatDirectoActivo = false;
}
