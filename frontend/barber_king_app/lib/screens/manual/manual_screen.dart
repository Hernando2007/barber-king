import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'manual_visor.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final GlobalKey<VisorManualEstado> _visor = GlobalKey<VisorManualEstado>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manual de usuario'),
        actions: [
          IconButton(
            tooltip: 'Actualizar manual',
            onPressed: () => _visor.currentState?.recargar(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: SafeArea(child: VisorManual(key: _visor)),
    );
  }
}
