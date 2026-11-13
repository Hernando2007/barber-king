import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_king_app/core/theme.dart';
import 'package:barber_king_app/widgets/admin/admin_cajon.dart';

/// Pantalla de ensayo con el cajón montado como lo tiene el panel real.
class _PanelDeEnsayo extends StatefulWidget {
  const _PanelDeEnsayo({this.destino});

  /// Destino cuyo tap debe quedar registrado.
  final DestinoCajon? destino;

  @override
  State<_PanelDeEnsayo> createState() => _PanelDeEnsayoState();
}

class _PanelDeEnsayoState extends State<_PanelDeEnsayo> {
  int taps = 0;
  int salidas = 0;

  static const usuario = {
    'nombres': 'Ana',
    'apellidos': 'Pérez',
    'email': 'ana@barberking.com',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barber King')),
      drawer: AdminCajon(
        usuario: usuario,
        destinos: [
          const DestinoCajon(
            etiqueta: 'Panel de control',
            detalle: 'Resumen y actividad de hoy',
            icono: Icons.dashboard_outlined,
            actual: true,
            onTap: _sinAccion,
          ),
          if (widget.destino != null) widget.destino!,
        ],
        onPerfil: () => setState(() => taps++),
        onSalir: () => setState(() => salidas++),
      ),
      body: const Center(child: Text('CONTENIDO_DEL_PANEL')),
    );
  }
}

void _sinAccion() {}

DestinoCajon _destinoDePrueba(VoidCallback onTap) => DestinoCajon(
  etiqueta: 'Servicios',
  detalle: 'Catálogo y precios',
  icono: Icons.content_cut_rounded,
  contador: 3,
  onTap: onTap,
);

void main() {
  Future<void> montar(WidgetTester tester, {DestinoCajon? destino}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: _PanelDeEnsayo(destino: destino),
      ),
    );
  }

  Future<void> abrirCajon(WidgetTester tester) async {
    // AppBar con drawer agrega solo el botón ☰ (DrawerButton).
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
  }

  testWidgets('el botón ☰ despliega el cajón con sus destinos', (
    tester,
  ) async {
    await montar(tester);

    // Antes de abrir, el cajón no está montado (Drawer lo desmonta cerrado).
    expect(find.byType(AdminCajon), findsNothing);

    await abrirCajon(tester);

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('CONSOLA DE ADMINISTRACIÓN'), findsOneWidget);
    expect(find.text('Panel de control'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);
  });

  testWidgets('tocar un destino cierra el cajón y no saca la pantalla', (
    tester,
  ) async {
    int tocado = 0;
    await montar(tester, destino: _destinoDePrueba(() => tocado++));

    await abrirCajon(tester);
    await tester.tap(find.text('Servicios'));
    await tester.pumpAndSettle();

    // El cajón se cerró, la acción corrió y el panel sigue montado.
    expect(find.byType(Drawer), findsNothing);
    expect(tocado, 1);
    expect(find.text('CONTENIDO_DEL_PANEL'), findsOneWidget);
    expect(find.byType(AdminCajon), findsNothing);
  });

  testWidgets('cerrar sesión se invoca desde el pie del cajón', (
    tester,
  ) async {
    _PanelDeEnsayoState estado() =>
        tester.state<_PanelDeEnsayoState>(find.byType(_PanelDeEnsayo));

    await montar(tester);
    await abrirCajon(tester);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(estado().salidas, 1);
    expect(find.text('CONTENIDO_DEL_PANEL'), findsOneWidget);
  });

  testWidgets('el destino actual se resalta y muestra el contador de avisos', (
    tester,
  ) async {
    await montar(tester, destino: _destinoDePrueba(() {}));
    await abrirCajon(tester);

    // Píldora roja con el contador del destino (3 avisos pendientes).
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Panel de control'), findsOneWidget);
  });
}
