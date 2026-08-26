import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/usuario_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({
    super.key,
  });

  @override
  State<PerfilScreen> createState() =>
      _PerfilScreenState();
}

class _PerfilScreenState
    extends State<PerfilScreen> {

  final UsuarioService usuarioService =
      UsuarioService();

  final AuthService authService =
      AuthService();

  Map<String, dynamic>? usuario;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {

    final data =
        await authService.obtenerUsuario();

    if (!mounted) return;

    setState(() {
      usuario = data;
      cargando = false;
    });
  }

  Widget item(
    String titulo,
    String valor,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
        ),
      ),

      body: cargando

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        AppColors.primary,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    "${usuario?["nombres"] ?? ""} ${usuario?["apellidos"] ?? ""}",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  item(
                    "Correo",
                    usuario?["correo"] ??
                        "",
                  ),

                  item(
                    "Teléfono",
                    usuario?["telefono"] ??
                        "",
                  ),

                  item(
                    "Rol",
                    usuario?["rol"] ??
                        "Cliente",
                  ),

                  item(
                    "Estado",
                    usuario?["estado"] ==
                            true
                        ? "Activo"
                        : "Inactivo",
                  ),
                ],
              ),
            ),
    );
  }
}