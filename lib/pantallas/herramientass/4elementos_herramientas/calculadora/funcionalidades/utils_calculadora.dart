/// CONSTANTES Y ESTILOS DE CALCULADORA
/// Centraliza la paleta de colores y estilos visuales específicos
/// para mantener la consistencia en el diseño de la herramienta.
import 'package:flutter/material.dart';

class UtilsCalculadora {
  // Colores de Fondo
  static const Color fondoInicio = Color(0xFFF2FBF5);
  static const Color fondoFin = Color(0xFFF9FDFB);
  static const Color colorDisplayBg = Color(0xFFF7FFF8);
  static const Color colorDisplayBorder = Color(0xFFCFF6E8);

  // Colores de Texto e Iconos
  static const Color colorPrincipal = Color(0xFF10B981); // Verde principal
  static const Color colorTextoOscuro = Color(0xFF22223B);
  static const Color colorTextoGris = Color(0xFF6B7280);
  static const Color colorFlechaBack = Color(0xFF374151);

  // Colores de Botones
  static const Color btnBlancoBorde = Color(0xFFE6F5EB);
  static const Color btnRojoTexto = Color(0xFFEF4444);
  static const Color btnRojoBorde = Color(0xFFFEE2E2);
  static const Color btnNaranjaTexto = Color(0xFFFFA726);
  static const Color btnNaranjaBorde = Color(0xFFFFF7ED);
  static const Color btnAmarilloTexto = Color(0xFFF59E0B);

  // Gradientes
  static const LinearGradient gradienteFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [fondoInicio, fondoFin],
  );

  static const LinearGradient gradienteVerde = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
  );
}