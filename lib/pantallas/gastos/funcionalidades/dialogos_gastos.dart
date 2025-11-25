// DialogoEliminarGasto: Diálogo para confirmar la eliminación de un gasto.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/gastos_servicio.dart';

class DialogoEliminarGasto extends StatelessWidget {
  final String gastoId;
  final VoidCallback onEliminado;

  const DialogoEliminarGasto({
    super.key,
    required this.gastoId,
    required this.onEliminado,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Eliminar Gasto'),
      content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            _procesarEliminacion(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }

  Future<void> _procesarEliminacion(BuildContext context) async {
    final GastosServicio servicio = GastosServicio();
    
    // Mostrar carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final error = await servicio.eliminarGasto(gastoId);
      
      // Cerrar carga
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gasto eliminado correctamente'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          onEliminado();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}