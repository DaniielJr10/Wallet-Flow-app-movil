import 'package:flutter/material.dart';

/// Widget para mostrar el detalle de una deuda y su historial de pagos en un modal.
class DetalleDeudaModal extends StatelessWidget {
  final Map<String, dynamic> deuda;
  final Function(Map<String, dynamic>) onEditar;
  final Function(Map<String, dynamic>) onEliminar;

  const DetalleDeudaModal({
    super.key,
    required this.deuda,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar el modal de detalles aquí
    return Container();
  }
}
