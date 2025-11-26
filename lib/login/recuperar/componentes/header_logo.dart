/// COMPONENTE DE LOGO
/// Muestra la imagen corporativa. Incluye un contenedor de respaldo (fallback)
/// con un icono y degradado en caso de que la imagen no cargue.
import 'package:flutter/material.dart';
import 'utils_recuperar.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsRecuperar.colorPrincipal, Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: UtilsRecuperar.colorPrincipal.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 50,
            ),
          );
        },
      ),
    );
  }
}