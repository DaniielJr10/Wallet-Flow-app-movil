/// COMPONENTE DE TEXTOS
/// Muestra el título principal y el párrafo explicativo con instrucciones
/// para el usuario sobre cómo restablecer su contraseña.
import 'package:flutter/material.dart';
import 'utils_recuperar.dart';

class HeaderTitulo extends StatelessWidget {
  const HeaderTitulo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: UtilsRecuperar.colorTexto,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Ingresa tu correo electrónico registrado y te enviaremos un enlace para restablecer tu contraseña. Recuerda revisar tu bandeja de entrada y también la carpeta de spam.',
          style: TextStyle(
            fontSize: 16,
            color: UtilsRecuperar.colorSecundario.withOpacity(0.8),
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