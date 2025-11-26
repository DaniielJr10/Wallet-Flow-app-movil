/// UTILIDADES DE INGRESOS
/// Contiene la paleta de colores (Tema Verde), listas de categorías estáticas,
/// métodos para obtener iconos y helpers para formateo de fechas y textos.
import 'package:flutter/material.dart';

class UtilsIngresos {
  // Colores (Tema Verde)
  static const Color colorPrincipal = Color(0xFF2ecc71);
  static const Color colorSecundario = Color(0xFF27ae60);
  static const Color colorFondo = Color(0xFFF8FAFC);
  static const Color colorTexto = Color(0xFF1F2937);

  // Listas
  static const List<String> categorias = [
    'trabajo',
    'negocio',
    'freelance',
    'inversiones',
    'regalo',
    'ventas',
    'renta',
    'bonificacion',
    'otro'
  ];

  static const List<String> metodosPago = [
    'Efectivo',
    'Transferencia',
  ];

  // Iconos
  static IconData obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'trabajo': return Icons.work_rounded;
      case 'negocio': return Icons.business_rounded;
      case 'freelance': return Icons.laptop_rounded;
      case 'inversiones': return Icons.trending_up_rounded;
      case 'regalo': return Icons.card_giftcard_rounded;
      case 'ventas': return Icons.sell_rounded;
      case 'renta': return Icons.house_rounded;
      case 'bonificacion': return Icons.star_rounded;
      case 'otro': return Icons.attach_money_rounded;
      default: return Icons.attach_money_rounded;
    }
  }

  // Helpers
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  static String getNombreMes(int mes) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return meses[mes - 1];
  }
}