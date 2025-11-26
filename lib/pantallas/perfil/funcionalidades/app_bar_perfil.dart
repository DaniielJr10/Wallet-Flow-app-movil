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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: UtilsPerfil.colorHeaderInicio,
      elevation: 0,
      actions: [
        if (modoEdicion) ...[
          // Botón cancelar
          IconButton(
            onPressed: onCancelar,
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Cancelar',
          ),
          // Botón guardar con animación
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
                      color: Colors.white,
                    ),
                  );
                },
              ),
            )
          else
            IconButton(
              onPressed: onGuardar,
              icon: const Icon(Icons.save, color: Colors.white),
              tooltip: 'Guardar cambios',
            ),
        ] else
          // Botón editar
          IconButton(
            onPressed: onEditar,
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar perfil',
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          modoEdicion ? 'Editar Perfil' : 'Mi Perfil',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UtilsPerfil.colorHeaderInicio,
                UtilsPerfil.colorHeaderFin,
              ],
            ),
          ),
        ),
      ),
    );
  }
}