// Funciones utilitarias para la pantalla de login
import 'package:flutter/material.dart';

class UtilsLogin {
  // Colores corporativos
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorSecundario = Color(0xFF059669);
  static const Color colorTexto = Color(0xFF065F46);
  static const Color colorFondo = Color(0xFFE8F5E8);
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

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }
}