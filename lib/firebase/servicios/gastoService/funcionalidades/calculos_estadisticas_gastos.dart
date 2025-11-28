// 5. Totales y Estadísticas
// Cálculos matemáticos sobre los gastos.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_gastos.dart';

mixin CalculosEstadisticasGastos on ReferenciasGastos {
  
  /// === OBTENER TOTAL DE GASTOS POR PERÍODO ===
  Future<double> obtenerTotalGastos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? categoria,
  }) async {
    try {
      if (userId == null) return 0.0;
      
      Query<Map<String, dynamic>> query = gastosRef()
          .where('activo', isEqualTo: true);
      
      if (fechaInicio != null) {
        query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio));
      }
      
      if (fechaFin != null) {
        query = query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));
      }
      
      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }
      
      final snapshot = await query.get();
      double total = 0.0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] as num?)?.toDouble() ?? 0.0;
        total += monto;
      }
      
      return total;
      
    } catch (e) {
      return 0.0;
    }
  }
}