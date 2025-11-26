import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio principal que obtiene y calcula datos resumidos
/// para mostrar en la pantalla principal de Wallet Flow
class PrincipalServicio {
  /// Suma el monto pendiente de todas las deudas del usuario
  Future<double> _obtenerTotalDeudas() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get _userId => _auth.currentUser?.uid;

  /// Obtiene el resumen financiero completo del usuario
  Stream<Map<String, dynamic>> obtenerResumenFinanciero() {
    if (_userId == null) {
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

  /// Combina los streams de cuentas, ingresos y gastos
  Stream<Map<String, dynamic>> _combinarStreams() async* {
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      try {
        // Obtener datos en paralelo (incluye ahorros y deudas)
        final futures = await Future.wait([
          _obtenerTotalCuentas(),
          _obtenerTotalIngresos(),
          _obtenerTotalGastos(),
          _obtenerIngresosDelMes(),
          _obtenerGastosDelMes(),
          _obtenerTotalAhorros(),
          _obtenerTotalDeudas(),
        ]);

        final totalCuentas = futures[0];
        final totalIngresos = futures[1];
        final totalGastos = futures[2];
        final ingresosDelMes = futures[3];
        final gastosDelMes = futures[4];
        final totalAhorros = futures[5];
        final totalDeudas = futures[6];

        final balanceTotal = totalIngresos - totalGastos;

        yield {
          'totalCuentas': totalCuentas,
          'totalIngresos': totalIngresos,
          'totalGastos': totalGastos,
          'balanceTotal': balanceTotal,
          'ingresosDelMes': ingresosDelMes,
          'gastosDelMes': gastosDelMes,
          'totalAhorros': totalAhorros,
          'totalDeudas': totalDeudas,
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

  /// Obtiene el total de todas las cuentas
  Future<double> _obtenerTotalCuentas() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
  Future<double> _obtenerTotalIngresos() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
  Future<double> _obtenerTotalGastos() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
  Future<double> _obtenerIngresosDelMes() async {
    try {
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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
  Future<double> _obtenerGastosDelMes() async {
    try {
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
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

  /// Obtiene estadísticas rápidas para la pantalla principal
  Future<Map<String, dynamic>> obtenerEstadisticasRapidas() async {
    try {
      final futures = await Future.wait([
        _obtenerTotalCuentas(),
        _obtenerTotalIngresos(),
        _obtenerTotalGastos(),
        _obtenerIngresosDelMes(),
        _obtenerGastosDelMes(),
        _obtenerTotalAhorros(),
        _obtenerTotalDeudas(),
      ]);

      final totalCuentas = futures[0];
      final totalIngresos = futures[1];
      final totalGastos = futures[2];
      final ingresosDelMes = futures[3];
      final gastosDelMes = futures[4];
      final totalAhorros = futures[5];
      final totalDeudas = futures[6];

      return {
        'totalCuentas': totalCuentas,
        'totalIngresos': totalIngresos,
        'totalGastos': totalGastos,
        'balanceTotal': totalIngresos - totalGastos,
        'ingresosDelMes': ingresosDelMes,
        'gastosDelMes': gastosDelMes,
        'balanceMensual': ingresosDelMes - gastosDelMes,
        'totalAhorros': totalAhorros,
        'totalDeudas': totalDeudas,
      };
    } catch (e) {
      return {
        'error': 'Error al cargar estadísticas: $e',
        'totalCuentas': 0.0,
        'totalIngresos': 0.0,
        'totalGastos': 0.0,
        'balanceTotal': 0.0,
        'ingresosDelMes': 0.0,
        'gastosDelMes': 0.0,
        'balanceMensual': 0.0,
        'totalAhorros': 0.0,
        'totalDeudas': 0.0,
      };
    }
    }

    /// Obtiene el total real de ahorros del usuario (suma de montoActual de todas las metas)
    Future<double> _obtenerTotalAhorros() async {
      try {
        final snapshot = await _firestore
            .collection('usuarios')
            .doc(_userId)
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
}
