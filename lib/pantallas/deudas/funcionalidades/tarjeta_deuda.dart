import 'package:flutter/material.dart';

/// Widget para mostrar una tarjeta/lista de deuda.
class TarjetaDeuda extends StatelessWidget {
  final Map<String, dynamic> deuda;
  final int index;
  final Function(Map<String, dynamic>) onTap;

  const TarjetaDeuda({
    super.key,
    required this.deuda,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar tarjeta de deuda aquí
    return Container();
  }
}
