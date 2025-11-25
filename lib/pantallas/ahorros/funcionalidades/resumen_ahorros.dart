import 'package:flutter/material.dart';

/// Widget para mostrar el resumen financiero de los ahorros.
class ResumenAhorros extends StatelessWidget {
  final double totalAhorrado;
  final double totalMetas;
  final int totalMetasCount;
  final int metasCompletadas;
  final double progresoPorcentaje;

  const ResumenAhorros({
    super.key,
    required this.totalAhorrado,
    required this.totalMetas,
    required this.totalMetasCount,
    required this.metasCompletadas,
    required this.progresoPorcentaje,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar resumen financiero aquí
    return Container();
  }
}
