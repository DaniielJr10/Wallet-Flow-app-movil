// DialogoEliminarGasto: Diálogo para confirmar la eliminación de un gasto.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/gastoService/gastos_servicio.dart';

class DialogoEliminarGasto extends StatelessWidget {
  final String gastoId;
  final VoidCallback onEliminado;
  final BuildContext parentContext;

  const DialogoEliminarGasto({
    super.key,
    required this.gastoId,
    required this.onEliminado,
    required this.parentContext,
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
          onPressed: () {
            // Cerrar diálogo de confirmación y actualizar UI de forma optimista
            Navigator.pop(context);
            try {
              onEliminado();
            } catch (_) {}
            // Ejecutar eliminación en background sin overlay que bloquee la UI
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
    try {
      // Ejecutar eliminación en background con timeout
      final error = await servicio.eliminarGasto(gastoId).timeout(const Duration(seconds: 15));

      await Future.delayed(const Duration(milliseconds: 300));
      if (error == null) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('Gasto eliminado correctamente'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}