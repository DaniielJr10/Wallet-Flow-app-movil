/// GESTIÓN DE INGRESOS RECURRENTES SIMPLE
/// Muestra los ingresos normales que tienen los 3 campos de recurrencia.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/ingresoService/funcionalidades/recurrencia_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'frecuencia.dart';

class PantallaGestionRecurrencias extends StatefulWidget {
  const PantallaGestionRecurrencias({super.key});

  @override
  State<PantallaGestionRecurrencias> createState() =>
      _PantallaGestionRecurrenciasState();
}

class _PantallaGestionRecurrenciasState
    extends State<PantallaGestionRecurrencias> {
  final RecurrenciaServicio _servicio = RecurrenciaServicio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos Recurrentes'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _servicio.obtenerIngresosRecurrentes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final ingresos = snapshot.data?.docs ?? [];

          if (ingresos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes ingresos recurrentes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea uno desde el formulario marcando frecuencia',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ingresos.length,
            itemBuilder: (context, index) {
              final ingreso = ingresos[index];
              final datos = ingreso.data() as Map<String, dynamic>;

              return _buildTarjetaIngreso(ingreso.id, datos);
            },
          );
        },
      ),
    );
  }

  Widget _buildTarjetaIngreso(String id, Map<String, dynamic> datos) {
    final monto = (datos['monto'] ?? 0.0).toDouble();
    final descripcion = datos['descripcion'] ?? '';
    final categoria = datos['categoria'] ?? '';
    final frecuenciaStr = datos['frecuencia'] ?? '';
    final metodoPago = datos['metodoPago'] ?? '';

    final proximaFecha = datos['proximaFecha'] != null
        ? (datos['proximaFecha'] as Timestamp).toDate()
        : null;

    final frecuencia = FrecuenciaUtils.desdeString(frecuenciaStr);
    final frecuenciaTexto = frecuencia != null
        ? FrecuenciaUtils.obtenerNombre(frecuencia)
        : 'Sin frecuencia';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        descripcion,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Categoría: $categoria',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatoNumeros.formatearNumero(monto),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  frecuenciaTexto,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.payment,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  metodoPago,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (proximaFecha != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Próximo: ${_formatearFecha(proximaFecha)}',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmarDesactivacion(id, descripcion),
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Quitar Recurrencia'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  void _confirmarDesactivacion(String id, String descripcion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quitar recurrencia'),
          content: Text(
            '¿Deseas quitar la recurrencia de "$descripcion"?\n\n'
            'Se convertirá en un ingreso normal y no se generarán más automáticamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _quitarRecurrencia(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Quitar'),
            ),
          ],
        );
      },
    );
  }

  void _quitarRecurrencia(String id) async {
    final error = await _servicio.desactivarIngresoRecurrente(id);

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurrencia eliminada. Ahora es un ingreso normal.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
