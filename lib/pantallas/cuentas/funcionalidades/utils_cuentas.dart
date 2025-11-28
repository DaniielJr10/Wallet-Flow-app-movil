/// UTILIDADES COMPARTIDAS
/// Clase estática que centraliza la lógica visual repetitiva:
/// - Asignación de colores según el tipo de cuenta.
/// - Asignación de iconos según el tipo de cuenta.
import 'package:flutter/material.dart';

class UtilsCuentas {
  static Color obtenerColorTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return const Color(0xFF10B981);
      case 'corriente':
        return const Color(0xFF3B82F6);
      case 'credito':
        return const Color(0xFF8B5CF6);
      case 'inversion':
        return const Color(0xFFF59E0B);
      case 'dinero_en_mano':
        return const Color(0xFF10B981); // Verde para efectivo
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData obtenerIconoTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return Icons.savings_outlined;
      case 'corriente':
        return Icons.account_balance_outlined;
      case 'credito':
        return Icons.credit_card_outlined;
      case 'inversion':
        return Icons.trending_up_outlined;
      case 'dinero_en_mano':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  static String obtenerNombreTipoCuenta(String tipo) {
    switch (tipo) {
      case 'ahorros':
        return 'Cuenta de Ahorros';
      case 'corriente':
        return 'Cuenta Corriente';
      case 'dinero_en_mano':
        return 'Dinero en mano';
      default:
        return 'Cuenta';
    }
  }
}