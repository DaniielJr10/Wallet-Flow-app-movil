/// LINK DE NAVEGACIÓN
/// Permite al usuario regresar a la pantalla de Login si ya tiene cuenta.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class LinkLogin extends StatelessWidget {
  final VoidCallback onTap;

  const LinkLogin({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta? ',
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
              color: UtilsRegistro.colorSecundario,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: UtilsRegistro.colorSecundario,
            ),
          ),
        ),
      ],
    );
  }
}