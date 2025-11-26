/// ARCHIVO DE UTILIDADES
/// Contiene las constantes de colores, estilos compartidos y la lógica
/// pura de validación para no ensuciar los widgets visuales.
import 'package:flutter/material.dart';

class UtilsRecuperar {
  // Colores
  static const Color colorFondo = Color(0xFFE8F5E8);
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorSecundario = Color(0xFF059669);
  static const Color colorTexto = Color(0xFF065F46);
  static const Color colorError = Color(0xFFEF4444);

  // Validadores
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }
}