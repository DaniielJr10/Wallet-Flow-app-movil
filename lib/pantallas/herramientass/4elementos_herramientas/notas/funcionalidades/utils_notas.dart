/// UTILIDADES DE NOTAS
/// Centraliza la paleta de colores (Tema Naranja/Verde), constantes de diseño
/// y la función auxiliar para formatear fechas desde ISO8601.
import 'package:flutter/material.dart';

class UtilsNotas {
  // Colores principales - Tema moderno verde/menta
  static const Color colorFondo = Color(0xFFF0F9FF);
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorSecundario = Color(0xFF34D399);
  static const Color colorAccento = Color(0xFF059669);
  static const Color colorTextoTitulo = Color(0xFF047857);
  static const Color colorTextoGris = Color(0xFF6B7280);
  static const Color colorTextoOscuro = Color(0xFF111827);
  static const Color colorDelete = Color(0xFFEF4444);

  // Estilos de contenedores
  static const Color colorCardBg = Colors.white;
  static const Color colorInputBg = Color(0xFFF0FDF4);
  static const Color colorTagBg = Color(0xFFD1FAE5);
  static final Color colorSombra = Colors.green.withOpacity(0.08);
  static const Color colorBorde = Color(0xFFD1FAE5);

  // Helper de fecha
  static String formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      const months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }
}