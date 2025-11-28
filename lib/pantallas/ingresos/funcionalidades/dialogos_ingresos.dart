/// DIÁLOGOS DE CONFIRMACIÓN
/// Muestra alertas críticas, como la confirmación antes de eliminar un registro,
/// para evitar acciones accidentales.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/ingresoService/ingresos_servicio.dart';

class DialogoEliminarIngreso extends StatelessWidget {
  final String ingresoId;
  final VoidCallback onEliminado;

  const DialogoEliminarIngreso({
    super.key,
    required this.ingresoId,
    required this.onEliminado,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar ingreso'),
      content: const Text('¿Estás seguro de que deseas eliminar este ingreso? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(context);
            _eliminar(context);
          },
          child: const Text('Eliminar'),
        ),
      ],
    );
  }

  Future<void> _eliminar(BuildContext context) async {
    final IngresosServicio servicio = IngresosServicio();
    try {
      final error = await servicio.eliminarIngreso(ingresoId);
      if (error == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Ingreso eliminado correctamente'), backgroundColor: Colors.red.shade600),
          );
          onEliminado();
        }
      }
    } catch (e) {
      // Manejo de error silencioso o toast
    }
  }
}