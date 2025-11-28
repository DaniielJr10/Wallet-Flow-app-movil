// 3. Cálculos de totales (Futures)
// Métodos individuales para obtener sumas de colecciones.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_principal.dart';

mixin CalculosTotales on ReferenciasPrincipal {
  
  /// Obtiene el total de todas las cuentas
  Future<double> obtenerTotalCuentas() async {
    try {
      if (userId == null) return 0.0;
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('cuentas')
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final saldo = (data['saldo'] ?? 0.0);
        total += (saldo is num) ? saldo.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener total de cuentas: $e');
      return 0.0;
    }
  }

  /// Obtiene el total de todos los ingresos
  Future<double> obtenerTotalIngresos() async {
    try {
      if (userId == null) return 0.0;
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('ingresos')
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] ?? 0.0);
        total += (monto is num) ? monto.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener total de ingresos: $e');
      return 0.0;
    }
  }

  /// Obtiene el total de todos los gastos
  Future<double> obtenerTotalGastos() async {
    try {
      if (userId == null) return 0.0;
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('gastos')
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] ?? 0.0);
        total += (monto is num) ? monto.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener total de gastos: $e');
      return 0.0;
    }
  }

  /// Obtiene los ingresos del mes actual
  Future<double> obtenerIngresosDelMes() async {
    try {
      if (userId == null) return 0.0;
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('ingresos')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finMes))
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] ?? 0.0);
        total += (monto is num) ? monto.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener ingresos del mes: $e');
      return 0.0;
    }
  }

  /// Obtiene los gastos del mes actual
  Future<double> obtenerGastosDelMes() async {
    try {
      if (userId == null) return 0.0;
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('gastos')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finMes))
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final monto = (data['monto'] ?? 0.0);
        total += (monto is num) ? monto.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener gastos del mes: $e');
      return 0.0;
    }
  }

  /// Obtiene el total real de ahorros del usuario
  Future<double> obtenerTotalAhorros() async {
    try {
      if (userId == null) return 0.0;
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('ahorros')
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final montoActual = (data['montoActual'] ?? 0.0);
        total += (montoActual is num) ? montoActual.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener total de ahorros: $e');
      return 0.0;
    }
  }

  /// Suma el monto pendiente de todas las deudas del usuario
  Future<double> obtenerTotalDeudas() async {
    try {
      if (userId == null) return 0.0;
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('deudas')
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final montoPendiente = (data['montoPendiente'] ?? 0.0);
        total += (montoPendiente is num) ? montoPendiente.toDouble() : 0.0;
      }
      return total;
    } catch (e) {
      print('Error al obtener total de deudas: $e');
      return 0.0;
    }
  }

  /// Obtiene estadísticas rápidas (Future) para la pantalla principal
  Future<Map<String, dynamic>> obtenerEstadisticasRapidas() async {
    try {
      final futures = await Future.wait([
        obtenerTotalCuentas(),
        obtenerTotalIngresos(),
        obtenerTotalGastos(),
        obtenerIngresosDelMes(),
        obtenerGastosDelMes(),
        obtenerTotalAhorros(),
        obtenerTotalDeudas(),
      ]);

      final totalIngresos = futures[1];
      final totalGastos = futures[2];
      final ingresosDelMes = futures[3];
      final gastosDelMes = futures[4];

      return {
        'totalCuentas': futures[0],
        'totalIngresos': totalIngresos,
        'totalGastos': totalGastos,
        'balanceTotal': totalIngresos - totalGastos,
        'ingresosDelMes': ingresosDelMes,
        'gastosDelMes': gastosDelMes,
        'balanceMensual': ingresosDelMes - gastosDelMes,
        'totalAhorros': futures[5],
        'totalDeudas': futures[6],
      };
    } catch (e) {
      return {
        'error': 'Error al cargar estadísticas: $e',
        'totalCuentas': 0.0,
        // ... valores por defecto
      };
    }
  }
}