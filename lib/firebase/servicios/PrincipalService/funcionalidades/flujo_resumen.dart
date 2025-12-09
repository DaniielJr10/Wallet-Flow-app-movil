// 4. Stream en tiempo real del resumen financiero
// Combina streams de Firestore para actualizaciones inmediatas cuando cambian los datos.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referencias_principal.dart';
import 'calculos_totales.dart';

mixin FlujoResumen on ReferenciasPrincipal, CalculosTotales {
  
  /// Obtiene el resumen financiero completo del usuario
  /// Se actualiza automáticamente cuando cambian los datos en Firestore
  Stream<Map<String, dynamic>> obtenerResumenFinanciero() {
    if (userId == null) {
      return Stream.value({
        'totalCuentas': 0.0,
        'totalIngresos': 0.0,
        'totalGastos': 0.0,
        'balanceTotal': 0.0,
        'ingresosDelMes': 0.0,
        'gastosDelMes': 0.0,
        'totalAhorros': 0.0,
        'totalDeudas': 0.0,
        'error': null,
      });
    }

    // Combinar streams en tiempo real de todas las colecciones
    return _combinarStreamsEnTiempoReal();
  }

  /// Combina múltiples streams de Firestore para actualizaciones en tiempo real
  Stream<Map<String, dynamic>> _combinarStreamsEnTiempoReal() async* {
    late StreamSubscription cuentasSubscription;
    late StreamSubscription ingresosSubscription;
    late StreamSubscription gastosSubscription;
    late StreamSubscription ahorrosSubscription;
    late StreamSubscription deudasSubscription;

    final controller = StreamController<Map<String, dynamic>>();
    
    // Variables para almacenar los últimos valores
    double totalCuentas = 0.0;
    double totalIngresos = 0.0;
    double totalGastos = 0.0;
    double ingresosDelMes = 0.0;
    double gastosDelMes = 0.0;
    double totalAhorros = 0.0;
    double totalDeudas = 0.0;

    void emitirResumen() {
      if (!controller.isClosed) {
        final balanceTotal = totalIngresos - totalGastos;
        controller.add({
          'totalCuentas': totalCuentas,
          'totalIngresos': totalIngresos,
          'totalGastos': totalGastos,
          'balanceTotal': balanceTotal,
          'ingresosDelMes': ingresosDelMes,
          'gastosDelMes': gastosDelMes,
          'totalAhorros': totalAhorros,
          'totalDeudas': totalDeudas,
          'error': null,
        });
      }
    }

    try {
      // Stream de cuentas - suma todos los saldos
      cuentasSubscription = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('cuentas')
          .snapshots()
          .listen((snapshot) {
        double total = 0.0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final saldo = (data['saldo'] ?? 0.0);
          total += (saldo is num) ? saldo.toDouble() : 0.0;
        }
        totalCuentas = total;
        emitirResumen();
      });

      // Stream de ingresos - total y del mes actual
      ingresosSubscription = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('ingresos')
          .snapshots()
          .listen((snapshot) {
        double total = 0.0;
        double delMes = 0.0;
        
        final ahora = DateTime.now();
        final inicioMes = DateTime(ahora.year, ahora.month, 1);
        final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final monto = (data['monto'] ?? 0.0);
          final montoDouble = (monto is num) ? monto.toDouble() : 0.0;
          total += montoDouble;

          // Verificar si es del mes actual
          final fecha = data['fecha'] as Timestamp?;
          if (fecha != null) {
            final fechaDateTime = fecha.toDate();
            if (fechaDateTime.isAfter(inicioMes.subtract(const Duration(days: 1))) && 
                fechaDateTime.isBefore(finMes.add(const Duration(days: 1)))) {
              delMes += montoDouble;
            }
          }
        }
        totalIngresos = total;
        ingresosDelMes = delMes;
        emitirResumen();
      });

      // Stream de gastos - total y del mes actual
      gastosSubscription = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('gastos')
          .snapshots()
          .listen((snapshot) {
        double total = 0.0;
        double delMes = 0.0;
        
        final ahora = DateTime.now();
        final inicioMes = DateTime(ahora.year, ahora.month, 1);
        final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final monto = (data['monto'] ?? 0.0);
          final montoDouble = (monto is num) ? monto.toDouble() : 0.0;
          total += montoDouble;

          // Verificar si es del mes actual
          final fecha = data['fecha'] as Timestamp?;
          if (fecha != null) {
            final fechaDateTime = fecha.toDate();
            if (fechaDateTime.isAfter(inicioMes.subtract(const Duration(days: 1))) && 
                fechaDateTime.isBefore(finMes.add(const Duration(days: 1)))) {
              delMes += montoDouble;
            }
          }
        }
        totalGastos = total;
        gastosDelMes = delMes;
        emitirResumen();
      });

      // Stream de ahorros - total de montos ahorrados
      ahorrosSubscription = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('ahorros')
          .snapshots()
          .listen((snapshot) {
        double total = 0.0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final montoActual = (data['montoActual'] ?? 0.0);
          total += (montoActual is num) ? montoActual.toDouble() : 0.0;
        }
        totalAhorros = total;
        emitirResumen();
      });

      // Stream de deudas - total de montos pendientes
      deudasSubscription = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('deudas')
          .snapshots()
          .listen((snapshot) {
        double total = 0.0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final montoPendiente = (data['montoPendiente'] ?? 0.0);
          total += (montoPendiente is num) ? montoPendiente.toDouble() : 0.0;
        }
        totalDeudas = total;
        emitirResumen();
      });

      // Emitir valores iniciales
      emitirResumen();

      await for (final data in controller.stream) {
        yield data;
      }
    } catch (e) {
      yield {
        'totalCuentas': 0.0,
        'totalIngresos': 0.0,
        'totalGastos': 0.0,
        'balanceTotal': 0.0,
        'ingresosDelMes': 0.0,
        'gastosDelMes': 0.0,
        'totalAhorros': 0.0,
        'totalDeudas': 0.0,
        'error': 'Error al cargar datos: $e',
      };
    } finally {
      // Limpiar subscripciones
      cuentasSubscription.cancel();
      ingresosSubscription.cancel();
      gastosSubscription.cancel();
      ahorrosSubscription.cancel();
      deudasSubscription.cancel();
      controller.close();
    }
  }
}