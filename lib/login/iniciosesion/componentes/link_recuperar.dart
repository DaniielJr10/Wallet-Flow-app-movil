// Enlace para recuperar contraseña
import 'package:flutter/material.dart';
import 'utils_login.dart';

class LinkRecuperarPassword extends StatelessWidget {
  final VoidCallback onTap;

  const LinkRecuperarPassword({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: const Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: UtilsLogin.colorSecundario,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: UtilsLogin.colorSecundario,
        ),
      ),
    );
  }
}