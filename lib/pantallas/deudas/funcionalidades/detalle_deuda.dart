// Modal para mostrar el historial de pagos y detalles de una deuda.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_deudas.dart';
import 'dialogos_deudas.dart';
import '../../../firebase/servicios/DeudaService/deudas_servicio.dart';

class DetalleHistorialDeuda extends StatelessWidget {
  final Map<String, dynamic> deuda;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback? onPagoRealizado;

  const DetalleHistorialDeuda({
    super.key,
    required this.deuda,
    required this.onEditar,
    required this.onEliminar,
    this.onPagoRealizado,
  });

  @override
  Widget build(BuildContext context) {
    final historial = List<Map<String, dynamic>>.from(deuda['historialPagos'] ?? []);
    final colorEstado = UtilsDeudas.obtenerColorEstado(deuda);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    UtilsDeudas.obtenerIconoTipoDeuda(deuda['tipo']),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles de la Deuda',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deuda['titulo'],
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorEstado.withOpacity(0.25), width: 2),
                    ),
                    child: Text(
                      '-${FormatoNumeros.formatearParaMostrar(deuda['montoPendiente'])}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildDetalleRow('Nombre', deuda['titulo'], Icons.label_outline),
                  const SizedBox(height: 12),
                  _buildDetalleRow('Monto original', '\$${FormatoNumeros.formatearParaMostrar(deuda['montoOriginal'] ?? deuda['montoPendiente'])}', Icons.attach_money_rounded),
                  const SizedBox(height: 12),
                  _buildDetalleRow('Prestamista', deuda['prestamista'] ?? deuda['acreedor'] ?? '', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildDetalleRow('Fecha de la deuda', deuda['fechaDeuda'] != null ? UtilsDeudas.formatearFecha(_convertirADateTime(deuda['fechaDeuda'])) : '—', Icons.event),
                  const SizedBox(height: 12),
                  _buildDetalleRow('Fecha de vencimiento', deuda['fechaVencimiento'] != null ? UtilsDeudas.formatearFechaVencimiento(_convertirADateTime(deuda['fechaVencimiento'])) : '—', Icons.alarm),
                  const SizedBox(height: 12),
                  _buildDetalleRow('Categoría', deuda['tipo'], _obtenerIconoCategoria(deuda['tipo'])),
                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Historial de pagos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                  ),
                  const SizedBox(height: 8),
                  historial.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('No hay pagos registrados'),
                        )
                      : Column(
                          children: historial.map((pago) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.payment, color: Color(0xFFF97316)),
                              title: Text('\$${FormatoNumeros.formatearParaMostrar(pago['monto'])}'),
                              subtitle: Text(UtilsDeudas.formatearFecha(pago['fecha'])),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEditar();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final resultado = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (ctx) => DialogoPagoDeuda(
                          deuda: deuda,
                          onPagoRegistrado: () {},
                        ),
                      );
                      
                      if (resultado != null) {
                        Navigator.pop(context); // Cerrar modal de detalles
                        
                        // Procesar el pago
                        await _procesarPago(resultado['monto'], deuda);
                        
                        if (onPagoRealizado != null) {
                          onPagoRealizado!(); // Recargar lista
                        }
                      }
                    },
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Pagar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsDeudas.colorPrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEliminar();
                    },
                    icon: const Icon(Icons.delete_rounded, size: 18),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: UtilsDeudas.colorPrincipal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _obtenerIconoCategoria(String? tipo) {
    switch (tipo) {
      case 'Préstamo Personal':
        return Icons.person;
      case 'Préstamo Familiar/Amigos':
        return Icons.family_restroom;
      case 'Préstamo Estudiantil':
        return Icons.school;
      case 'Deuda por Servicios':
        return Icons.receipt_long;
      case 'Deuda Médica':
        return Icons.local_hospital;
      case 'Microcrédito':
        return Icons.savings;
      case 'Otro':
        return Icons.more_horiz;
      default:
        return Icons.receipt_long;
    }
  }

  DateTime _convertirADateTime(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    } else if (fecha is DateTime) {
      return fecha;
    }
    return DateTime.now();
  }

  Future<void> _procesarPago(double pago, Map<String, dynamic> deuda) async {
    try {
      final deudasServicio = DeudasServicio();
      
      // No permitir pagar más que la deuda
      final montoPend = (deuda['montoPendiente'] ?? 0).toDouble();
      final pagoFinal = pago > montoPend ? montoPend : pago;

      // Actualizar deuda
      double nuevoPend = montoPend - pagoFinal;
      String nuevoEstado = deuda['estado'] ?? 'Pendiente';
      if (nuevoPend <= 0) {
        nuevoPend = 0.0;
        nuevoEstado = 'Pagada';
      }

      final historial = List<Map<String, dynamic>>.from(deuda['historialPagos'] ?? []);
      historial.add({'monto': pagoFinal, 'fecha': DateTime.now()});

      await deudasServicio.editarDeuda(deuda['id'], {
        'montoPendiente': nuevoPend,
        'estado': nuevoEstado,
        'historialPagos': historial,
      });
    } catch (e) {
      debugPrint('Error al procesar pago: $e');
    }
  }
}