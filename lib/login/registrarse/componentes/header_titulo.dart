/// TÍTULOS DE BIENVENIDA
/// Muestra el encabezado "Crear Cuenta" y el subtítulo motivacional.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class HeaderTitulo extends StatelessWidget {
  const HeaderTitulo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Crear Cuenta',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: UtilsRegistro.colorTexto,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Únete a Wallet Flow y toma el control total de tus finanzas personales.',
          style: TextStyle(
            fontSize: 16,
            color: UtilsRegistro.colorSecundario.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}