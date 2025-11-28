// 4. Stream periódico del resumen financiero
// Combina los cálculos totales en un flujo continuo.

import 'dart:async';
import 'referencias_principal.dart';
import 'calculos_totales.dart';

mixin FlujoResumen on ReferenciasPrincipal, CalculosTotales {
  
  /// Obtiene el resumen financiero completo del usuario
  Stream<Map<String, dynamic>> obtenerResumenFinanciero() {
    if (userId == null) {
      return Stream.value({
        'totalCuentas': 0.0,
        'totalIngresos': 0.0,
        'totalGastos': 0.0,
        'balanceTotal': 0.0,
        'ingresosDelMes': 0.0,
        'gastosDelMes': 0.0,
        'error': null,
      });
    }

    // Combinar streams de todas las colecciones
    return _combinarStreams();
  }

  /// Combina los cálculos en un stream periódico
  Stream<Map<String, dynamic>> _combinarStreams() async* {
    // Emite cada segundo (o según se requiera)
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      try {
        // Obtener datos en paralelo usando los métodos de CalculosTotales
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
        
        yield {
          'totalCuentas': futures[0],
          'totalIngresos': totalIngresos,
          'totalGastos': totalGastos,
          'balanceTotal': totalIngresos - totalGastos,
          'ingresosDelMes': futures[3],
          'gastosDelMes': futures[4],
          'totalAhorros': futures[5],
          'totalDeudas': futures[6],
          'error': null,
        };
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
      }
    }
  }
}