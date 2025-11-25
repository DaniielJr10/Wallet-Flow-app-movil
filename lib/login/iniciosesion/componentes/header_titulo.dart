// Textos de bienvenida y subtítulo
import 'package:flutter/material.dart';
import 'utils_login.dart';

class HeaderTitulo extends StatelessWidget {
  const HeaderTitulo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Wallet Flow',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: UtilsLogin.colorTexto,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tus finanzas, bajo control',
          style: TextStyle(
            fontSize: 16,
            color: UtilsLogin.colorSecundario.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}