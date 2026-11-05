import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_king_app/core/theme.dart';
import 'package:barber_king_app/screens/home/pestana_scope.dart';
import 'package:barber_king_app/screens/home/tabs_home_screen.dart';

/// Pestaña de ensayo: cuenta cuántas veces se construyó su contenido.
class _ContadorPestana extends StatefulWidget {
  const _ContadorPestana(this.etiqueta, {this.irA});

  final String etiqueta;
  final String? irA;

  @override
  State<_ContadorPestana> createState() => _ContadorPestanaState();
}

class _ContadorPestanaState extends State<_ContadorPestana> {
  static final Map<String, int> construcciones = {};

  int vecesConstruida = 0;

  @override
  void initState() {
    super.initState();
    vecesConstruida++;
    construcciones[widget.etiqueta] =
        (construcciones[widget.etiqueta] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final ir = widget.irA;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.etiqueta}:${vecesConstruida}_'),
            if (ir != null)
              ElevatedButton(
                onPressed: () => PestanaScope.maybeOf(context)?.irARuta(ir),
                child: Text('ir a $ir'),
              ),
          ],
        ),
      ),
    );
  }
}

List<Pestana> _pestanasDeEnsayo() => [
  Pestana(
    etiqueta: 'Inicio',
    icono: Icons.home_outlined,
    construir: (_) => _ContadorPestana('Inicio', irA: '/citas'),
  ),
  const Pestana(
    etiqueta: 'Citas',
    ruta: '/citas',
    icono: Icons.event_available_outlined,
    construir: _construirCitas,
  ),
  const Pestana(
    etiqueta: 'Chats',
    ruta: '/chats',
    icono: Icons.chat_outlined,
    contarNoLeidos: true,
    construir: _construirChats,
  ),
];

Widget _construirCitas(_) => const _ContadorPestana('Citas');
Widget _construirChats(_) => const _ContadorPestana('Chats');

void main() {
  setUp(() => _ContadorPestanaState.construcciones.clear());

  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: TabsHomeScreen(pestanas: _pestanasDeEnsayo()),
      ),
    );
  }

  testWidgets('la barra pinta los destinos y arranca en el panel', (
    tester,
  ) async {
    await montar(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Citas'), findsOneWidget);

    // Solo el panel se construye: las otras pestañas esperan su visita.
    expect(_ContadorPestanaState.construcciones.containsKey('Citas'), false);
    expect(find.text('Inicio:1_'), findsOneWidget);
  });

  testWidgets('tocar un destino cambia el cuerpo una sola vez por pestaña', (
    tester,
  ) async {
    await montar(tester);

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('Chats:1_'), findsOneWidget);

    await tester.tap(find.text('Citas'));
    await tester.pumpAndSettle();
    expect(find.text('Citas:1_'), findsOneWidget);

    // Volver a Chats no vuelve a construir: conserva su estado.
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('Chats:1_'), findsOneWidget);
    expect(_ContadorPestanaState.construcciones['Chats'], 1);
  });

  testWidgets('irARuta salta de pestaña en vez de apilar una pantalla', (
    tester,
  ) async {
    await montar(tester);

    await tester.tap(find.text('ir a /citas'));
    await tester.pumpAndSettle();

    expect(find.text('Citas:1_'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('atrás regresa al panel y no cierra la app', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Citas'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Sigue montado el mismo árbol: el panel otra vez, sin pop real.
    expect(find.text('Inicio:1_'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
