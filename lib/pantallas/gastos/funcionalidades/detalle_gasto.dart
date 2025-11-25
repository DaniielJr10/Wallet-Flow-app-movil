import 'package:flutter/material.dart';

/// Widget para mostrar el detalle de un gasto en un modal.
class DetalleGastoModal extends StatelessWidget {
  final Map<String, dynamic> gasto;
  final Function(Map<String, dynamic>) onEditar;
  final Function(String) onEliminar;

  const DetalleGastoModal({
    super.key,
    required this.gasto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar el modal de detalles aquí
    return Container();
  }
}
