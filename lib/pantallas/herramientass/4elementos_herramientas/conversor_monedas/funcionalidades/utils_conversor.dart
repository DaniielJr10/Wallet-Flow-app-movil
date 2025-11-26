/// CONFIGURACIÓN DE CONVERSOR
/// Centraliza las tasas de cambio base (offline), la lista de monedas soportadas,
/// los colores de la UI y funciones auxiliares para etiquetas de monedas.
import 'package:flutter/material.dart';

class UtilsConversor {
  // Colores
  static const Color colorFondo = Color(0xFFF3F9F6);
  static const Color colorPrincipal = Color(0xFF10B981);
  static const Color colorTexto = Color(0xFF065F46);
  
  // Datos estáticos
  static const List<String> currencies = ['USD', 'EUR', 'COP', 'GBP', 'JPY', 'CAD', 'AUD'];
  
  static const Map<String, double> ratesBase = {
    'USD': 1.0,
    'EUR': 0.8603,
    'COP': 3758.0,
    'GBP': 0.759,
    'JPY': 154.51,
    'CAD': 1.3996,
    'AUD': 1.53,
  };

  // Helpers
  static String getCurrencyLabel(String code) {
    switch (code) {
      case 'USD': return 'Dólar (USD)';
      case 'EUR': return 'Euro (EUR)';
      case 'COP': return 'Peso Col. (COP)';
      case 'GBP': return 'Libra (GBP)';
      case 'JPY': return 'Yen (JPY)';
      case 'CAD': return 'Dólar Can. (CAD)';
      case 'AUD': return 'Dólar Aus. (AUD)';
      default: return code;
    }
  }
}