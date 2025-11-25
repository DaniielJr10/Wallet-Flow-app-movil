// Botón secundario para registro de usuario
import 'package:flutter/material.dart';
import 'utils_login.dart';

class BotonRegistro extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonRegistro({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: UtilsLogin.colorPrincipal,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: UtilsLogin.colorPrincipal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: UtilsLogin.colorSecundario,
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Registrarse',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}