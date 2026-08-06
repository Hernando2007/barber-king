import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../models/servicio.dart';

class ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback? onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const ServicioCard({
    super.key,
    required this.servicio,
    this.onTap,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.content_cut,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      servicio.nombre,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 15),

              Text(
                servicio.descripcion,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  const Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 18,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    "${servicio.duracion} min",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "\$${servicio.precio.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                ],
              ),

              if (onEditar != null || onEliminar != null) ...[
                const Divider(color: Colors.white24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    if (onEditar != null)
                      IconButton(
                        onPressed: onEditar,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                      ),

                    if (onEliminar != null)
                      IconButton(
                        onPressed: onEliminar,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),

                  ],
                ),
              ]

            ],
          ),
        ),
      ),
    );
  }
}