/// PANTALLA DE CARGA
/// Muestra un indicador de progreso y un icono animado mientras
/// se obtienen los datos del perfil desde Firebase.
import 'package:flutter/material.dart';
import 'utils_perfil.dart';

class EstadoCargandoPerfil extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const EstadoCargandoPerfil({super.key, required this.scaleAnimation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: UtilsPerfil.colorPrincipal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando tu perfil...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UtilsPerfil.colorPrincipal),
          ),
        ],
      ),
    );
  }
}