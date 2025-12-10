/// HEADER DE LA PANTALLA
/// Implementa un SliverAppBar dinámico que cambia sus botones de acción
/// (Editar, Guardar, Cancelar) según el estado de edición (`modoEdicion`) 
/// y muestra animaciones de carga cuando se está guardando.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class AppBarPerfil extends StatelessWidget {
  final bool modoEdicion;
  final bool guardando;
  final Animation<double> rotationAnimation;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;
  final VoidCallback onEditar;

  const AppBarPerfil({
    super.key,
    required this.modoEdicion,
    required this.guardando,
    required this.rotationAnimation,
    required this.onCancelar,
    required this.onGuardar,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent, // Sin fondo
      elevation: 0,
      actions: [
        if (modoEdicion) ...[
          IconButton(
            onPressed: onCancelar,
            icon: const Icon(Icons.close, color: Colors.grey),
            tooltip: 'Cancelar',
          ),
          if (guardando)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedBuilder(
                animation: rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: rotationAnimation.value * 2 * 3.14159,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          else
            IconButton(
              onPressed: onGuardar,
              icon: const Icon(Icons.save, color: Colors.grey),
              tooltip: 'Guardar cambios',
            ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Color(0xFF2ecc71), size: 26),
            const SizedBox(width: 8),
            Text(
              modoEdicion ? 'Editar Perfil' : 'Mi Perfil',
              style: const TextStyle(
                color: Color(0xFF2ecc71),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        background: null,
      ),
    );
  }
}