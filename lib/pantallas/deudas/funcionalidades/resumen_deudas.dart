import 'package:flutter/material.dart';

/// Widget para mostrar el resumen financiero de las deudas.
class ResumenDeudas extends StatelessWidget {
  final double totalDeudaPendiente;
  final double pagoMinimoMensual;
  final int deudasVencidas;
  final int totalDeudas;
  final int diasPromedioVencimiento;

  const ResumenDeudas({
    super.key,
    required this.totalDeudaPendiente,
    required this.pagoMinimoMensual,
    required this.deudasVencidas,
    required this.totalDeudas,
    required this.diasPromedioVencimiento,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar resumen financiero aquí
    return Container();
  }
}
