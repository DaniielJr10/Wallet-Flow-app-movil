// Diálogos y alertas de confirmación para acciones sobre deudas.
import 'package:flutter/material.dart';

class DialogoConfirmarEliminarDeuda extends StatelessWidget {
  final String tituloDeuda;
  final VoidCallback onConfirmar;

  const DialogoConfirmarEliminarDeuda({
    super.key,
    required this.tituloDeuda,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning, color: Colors.red),
          ),
          const SizedBox(width: 12),
          const Text('Eliminar Deuda'),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas eliminar la deuda "$tituloDeuda"?\n\nEsta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmar();
          },
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}