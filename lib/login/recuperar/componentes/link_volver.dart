/// ENLACE DE NAVEGACIÓN
/// Componente simple de texto interactivo para permitir al usuario
/// cancelar la operación y regresar a la pantalla de inicio de sesión.
import 'package:flutter/material.dart';
import 'utils_recuperar.dart';

class LinkVolverLogin extends StatelessWidget {
  final VoidCallback onTap;

  const LinkVolverLogin({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Recordaste tu contraseña? ',
          style: TextStyle(
            color: const Color(0xFF6B7280).withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Inicia Sesión',
            style: TextStyle(
              color: UtilsRecuperar.colorSecundario,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: UtilsRecuperar.colorSecundario,
            ),
          ),
        ),
      ],
    );
  }
}