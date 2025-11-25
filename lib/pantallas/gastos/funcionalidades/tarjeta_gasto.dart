import 'package:flutter/material.dart';

/// Widget para mostrar una tarjeta/lista de gasto.
class TarjetaGasto extends StatelessWidget {
  final Map<String, dynamic> gasto;
  final int index;
  final Function(Map<String, dynamic>) onTap;
  final Function(String) onEliminar;

  const TarjetaGasto({
    super.key,
    required this.gasto,
    required this.index,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar tarjeta de gasto aquí
    return Container();
  }
}
