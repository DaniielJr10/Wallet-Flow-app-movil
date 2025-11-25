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
    bool loaderShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Añadir timeout para evitar que la UI quede bloqueada indefinidamente
      final error = await servicio.eliminarGasto(gastoId).timeout(const Duration(seconds: 15));

      // Cerrar carga si aún está abierta
      if (loaderShown && context.mounted) {
        try {
          if (Navigator.canPop(context)) Navigator.pop(context);
        } catch (_) {}
        loaderShown = false;
      }

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
    } on Exception catch (e) {
      // Manejar timeout u otros errores y asegurarse de cerrar la carga
      if (loaderShown && context.mounted) {
        try {
          if (Navigator.canPop(context)) Navigator.pop(context);
        } catch (_) {}
        loaderShown = false;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Asegurar que el diálogo de carga quede cerrado
      if (loaderShown && context.mounted) {
        try {
          if (Navigator.canPop(context)) Navigator.pop(context);
        } catch (_) {}
      }
    }
  }
}