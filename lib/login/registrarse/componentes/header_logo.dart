/// COMPONENTE DE LOGO
/// Muestra el logo de la app o un icono de "Add Person" estilizado como fallback.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

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
                colors: [UtilsRegistro.colorPrincipal, Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: UtilsRegistro.colorPrincipal.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: Colors.white,
              size: 50,
            ),
          );
        },
      ),
    );
  }
}