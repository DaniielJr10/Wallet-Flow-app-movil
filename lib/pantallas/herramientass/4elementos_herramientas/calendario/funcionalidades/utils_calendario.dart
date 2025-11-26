/// UTILIDADES DE CALENDARIO
/// Centraliza la paleta de colores (Verde Esmeralda) y la lista de meses
/// en español para los encabezados.
import 'package:flutter/material.dart';

class UtilsCalendario {
  // Colores
  static const Color colorFondo = Color(0xFFF6FBF7);
  static const Color colorPrincipal = Color(0xFF10B981); // Verde Esmeralda
  static const Color colorTextoMes = Color(0xFF059669);
  static const Color colorTextoGris = Color(0xFF6B7280);
  static const Color colorBorde = Color(0xFFE6F4EA);
  
  // Decoraciones
  static Color colorFondoHoy = Colors.green.withOpacity(0.12);
  static Color colorSombra = Colors.green.withOpacity(0.06);

  // Datos
  static const List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
}