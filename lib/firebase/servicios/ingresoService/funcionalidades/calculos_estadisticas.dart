// 5. Totales y reportes
// Este archivo contiene la lógica matemática y de agregación de datos.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_base.dart';

mixin CalculosEstadisticas on ReferenciasBase {
  /// === OBTENER TOTAL DE INGRESOS ===
  Future<double> obtenerTotalIngresos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? categoria,
  }) async {
    try {
      if (userId == null) return 0.0;

      Query<Map<String, dynamic>> query = ingresosRef();

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

      for (var doc in snapshot.docs) {
        final monto = (doc.data()['monto'] as num).toDouble();
        total += monto;
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  /// === OBTENER ESTADÍSTICAS DE INGRESOS ===
  Future<Map<String, dynamic>> obtenerEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      if (userId == null) {
        return {'error': 'Usuario no autenticado'};
      }

      fechaFin ??= DateTime.now();
      fechaInicio ??= DateTime(fechaFin.year, fechaFin.month - 1, fechaFin.day);

      final query = ingresosRef()
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin));

      final snapshot = await query.get();

      double totalIngresos = 0;
      Map<String, double> ingresosPorCategoria = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] as num).toDouble();
        final categoria = data['categoria'] as String;

        totalIngresos += monto;
        ingresosPorCategoria[categoria] = 
            (ingresosPorCategoria[categoria] ?? 0) + monto;
      }

      return {
        'totalIngresos': totalIngresos,
        'cantidadIngresos': snapshot.docs.length,
        'ingresosPorCategoria': ingresosPorCategoria,
        'promedioIngreso': snapshot.docs.isNotEmpty ? totalIngresos / snapshot.docs.length : 0,
      };

    } catch (e) {
      return {'error': e.toString()};
    }
  }
}