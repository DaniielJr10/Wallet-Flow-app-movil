// 5. Totales, contadores y reportes estadísticos
// Este archivo contiene la lógica matemática sobre las cuentas.

import 'referencias_cuentas.dart';

mixin CalculosEstadisticasCuentas on ReferenciasCuentas {
  
  /// === CALCULAR SALDO TOTAL ===
  Future<double> calcularSaldoTotal() async {
    try {
      if (userId == null) return 0.0;

      final snapshot = await cuentasRef()
          .where('activa', isEqualTo: true)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final saldo = (data['saldo'] ?? 0.0) as num;
        total += saldo.toDouble();
      }

      return total;
    } catch (e) {
      print('Error al calcular saldo total: $e');
      return 0.0;
    }
  }

  /// === OBTENER NÚMERO DE CUENTAS ===
  Future<int> obtenerNumeroCuentas() async {
    try {
      if (userId == null) return 0;

      final snapshot = await cuentasRef()
          .where('activa', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error al obtener número de cuentas: $e');
      return 0;
    }
  }

  /// === OBTENER ESTADÍSTICAS COMPLETAS ===
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      if (userId == null) {
        return _estructuraVacia();
      }

      final snapshot = await cuentasRef()
          .where('activa', isEqualTo: true)
          .get();

      double saldoTotal = 0.0;
      Map<String, int> cuentasPorTipo = {};
      Map<String, double> saldoPorTipo = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final saldo = (data['saldo'] ?? 0.0) as num;
        final tipo = data['tipo'] ?? 'otro';

        saldoTotal += saldo.toDouble();

        // Contar cuentas por tipo
        cuentasPorTipo[tipo] = (cuentasPorTipo[tipo] ?? 0) + 1;

        // Sumar saldo por tipo
        saldoPorTipo[tipo] = (saldoPorTipo[tipo] ?? 0.0) + saldo.toDouble();
      }

      return {
        'totalCuentas': snapshot.docs.length,
        'saldoTotal': saldoTotal,
        'cuentaPorTipo': cuentasPorTipo,
        'saldoPorTipo': saldoPorTipo,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return _estructuraVacia();
    }
  }

  /// Helper para retornar estructura vacía en caso de error
  Map<String, dynamic> _estructuraVacia() {
    return {
      'totalCuentas': 0,
      'saldoTotal': 0.0,
      'cuentaPorTipo': <String, int>{},
      'saldoPorTipo': <String, double>{},
    };
  }
}