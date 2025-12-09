/// DETALLE DE AHORRO - ESTILO INGRESOS/GASTOS
/// Modal que muestra los detalles completos de un ahorro con el MISMO diseño que ingresos/gastos.
/// Sigue exactamente el patrón: Header + Monto destacado + Items de detalle + Botones

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class DetalleAhorroReal extends StatelessWidget {
  final Map<String, dynamic> ahorro;
  final Function() onEditar;
  final Function() onEliminar;

  const DetalleAhorroReal({
    super.key,
    required this.ahorro,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = ahorro['categoria'] ?? 'otros';
    final categoriaInfo = UtilsAhorros.obtenerInfoCategoria(categoria);
    final montoActual = (ahorro['montoActual'] ?? 0.0).toDouble();
    final montoObjetivo = (ahorro['montoObjetivo'] ?? 0.0).toDouble();
    final fechaObjetivo = ahorro['fechaObjetivo'] is DateTime 
        ? ahorro['fechaObjetivo'] as DateTime
        : (ahorro['fechaObjetivo'] is Timestamp 
            ? (ahorro['fechaObjetivo'] as Timestamp).toDate() 
            : DateTime.now());
    final fechaCreacion = ahorro['fechaCreacion'] is Timestamp 
        ? (ahorro['fechaCreacion'] as Timestamp).toDate() 
        : ahorro['fechaCreacion'] as DateTime?;
    
    final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo).clamp(0.0, 1.0) : 0.0;
    final diasRestantes = fechaObjetivo.difference(DateTime.now()).inDays;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header igual que ingresos/gastos
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsAhorros.colorPrincipal, UtilsAhorros.colorPrincipal],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(
                    categoriaInfo['icono'], 
                    color: Colors.white, 
                    size: 24
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles del Ahorro', 
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w700, 
                          color: Colors.white
                        )
                      ),
                      Text(
                        ahorro['nombre'] ?? 'Ahorro sin nombre', 
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.white.withOpacity(0.9), 
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2)
                  ),
                ),
              ],
            ),
          ),
          // Contenido igual que ingresos/gastos
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Monto destacado igual que ingresos/gastos
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: UtilsAhorros.colorPrincipal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: UtilsAhorros.colorPrincipal, width: 2),
                      ),
                      child: Text(
                        FormatoNumeros.formatearParaMostrar(montoActual),
                        style: const TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.w800, 
                          color: UtilsAhorros.colorPrincipal
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Items de detalle igual que ingresos/gastos
                  _buildDetalleItem('Nombre', ahorro['nombre'] ?? 'Sin nombre', Icons.savings_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Categoría', categoriaInfo['nombre'], Icons.category_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Monto Objetivo', FormatoNumeros.formatearParaMostrar(montoObjetivo), Icons.flag_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Progreso', '${(progreso * 100).toStringAsFixed(1)}% completado', Icons.trending_up_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem('Fecha Objetivo', _formatearFecha(fechaObjetivo), Icons.calendar_today_outlined),
                  const SizedBox(height: 20),
                  _buildDetalleItem(
                    'Estado', 
                    diasRestantes >= 0 
                        ? (diasRestantes == 0 ? 'Vence hoy' : '$diasRestantes días restantes')
                        : 'Meta vencida', 
                    Icons.schedule_outlined
                  ),
                  if (fechaCreacion != null) ...[
                    const SizedBox(height: 20),
                    _buildDetalleItem('Fecha de Creación', _formatearFecha(fechaCreacion), Icons.event_outlined),
                  ],
                ],
              ),
            ),
          ),
          // Botones igual que ingresos/gastos
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { 
                      Navigator.pop(context); 
                      onEditar(); 
                    },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 14)
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { 
                      Navigator.pop(context); 
                      onEliminar(); 
                    },
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 14)
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

  // Método _buildDetalleItem IGUAL que ingresos/gastos
  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              color: UtilsAhorros.colorPrincipal.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icono, color: UtilsAhorros.colorPrincipal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo, 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.grey.shade600
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  valor, 
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: Color(0xFF1F2937)
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}
