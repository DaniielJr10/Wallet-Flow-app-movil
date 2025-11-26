/// TÍTULO DE LA PANTALLA
/// Muestra el icono principal, el título "Conversor de Monedas" y una breve descripción.
import 'package:flutter/material.dart';
import 'utils_conversor.dart';

class HeaderConversor extends StatelessWidget {
  const HeaderConversor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 8),
        Icon(Icons.savings, color: UtilsConversor.colorPrincipal, size: 48),
        SizedBox(height: 8),
        Text(
          'Conversor de Monedas',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: UtilsConversor.colorPrincipal,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Convierte entre diferentes monedas de forma rápida y sencilla',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}