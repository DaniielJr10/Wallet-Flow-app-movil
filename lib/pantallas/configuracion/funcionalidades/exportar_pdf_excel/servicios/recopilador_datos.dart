/**
 * SERVICIO: Recopilación de datos
 * 
 * Centraliza la obtención de datos de todos los servicios
 * de Firebase para exportación
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../firebase/servicios/ingresoService/ingresos_servicio.dart';
import '../../../../../firebase/servicios/gastoService/gastos_servicio.dart';
import '../../../../../firebase/servicios/DeudaService/deudas_servicio.dart';
import '../../../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../modelos/datos_exportacion.dart';

class RecopiladorDatos {
  // Servicios de Firebase
  static final IngresosServicio _ingresosService = IngresosServicio();
  static final GastosServicio _gastosService = GastosServicio();
  static final DeudasServicio _deudasService = DeudasServicio();
  static final AhorrosServicio _ahorrosService = AhorrosServicio();
  static final CuentasServicio _cuentasService = CuentasServicio();

  /// Obtiene todos los datos de manera centralizada
  static Future<DatosExportacion> obtenerTodosLosDatos() async {
    try {
      // Obtener datos en paralelo para mejor rendimiento
      final futures = await Future.wait([
        _obtenerIngresos(),
        _obtenerGastos(),
        _obtenerDeudas(),
        _obtenerAhorros(),
        _obtenerCuentas(),
      ]);

      return DatosExportacion(
        ingresos: futures[0],
        gastos: futures[1],
        deudas: futures[2],
        ahorros: futures[3],
        cuentas: futures[4],
      );
    } catch (e) {
      throw Exception('Error al obtener datos: $e');
    }
  }

  /// Obtiene y normaliza los ingresos
  static Future<List<Map<String, dynamic>>> _obtenerIngresos() async {
    try {
      final ingresos = await _ingresosService.obtenerIngresos().first;
      return ingresos.map((ingreso) => {
        'descripcion': ingreso['descripcion'] ?? '',
        'categoria': ingreso['categoria'] ?? '',
        'monto': (ingreso['monto'] as num?)?.toDouble() ?? 0.0,
        'fecha': _formatearFecha(ingreso['fecha']),
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene y normaliza los gastos
  static Future<List<Map<String, dynamic>>> _obtenerGastos() async {
    try {
      final gastosSnapshot = await _gastosService.obtenerGastos().first;
      return gastosSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'descripcion': data['descripcion'] ?? data['nombre'] ?? '',
          'categoria': data['categoria'] ?? '',
          'monto': (data['monto'] as num?)?.toDouble() ?? 0.0,
          'fecha': _formatearFecha(data['fecha']),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene y normaliza las deudas
  static Future<List<Map<String, dynamic>>> _obtenerDeudas() async {
    try {
      final deudasRaw = await _deudasService.obtenerDeudasStream().first;
      return deudasRaw.map((deuda) => {
        'acreedor': deuda['nombreAcreedor'] ?? '',
        'montoTotal': (deuda['montoTotal'] as num?)?.toDouble() ?? 0.0,
        'montoPagado': (deuda['montoPagado'] as num?)?.toDouble() ?? 0.0,
        'montoRestante': ((deuda['montoTotal'] as num?)?.toDouble() ?? 0.0) - 
                        ((deuda['montoPagado'] as num?)?.toDouble() ?? 0.0),
        'fechaVencimiento': _formatearFecha(deuda['fechaVencimiento']),
        'estado': deuda['estado'] ?? 'Pendiente',
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene y normaliza los ahorros
  static Future<List<Map<String, dynamic>>> _obtenerAhorros() async {
    try {
      final ahorrosRaw = await _ahorrosService.obtenerMetasAhorro().first;
      return ahorrosRaw.map((ahorro) {
        final objetivo = (ahorro['montoObjetivo'] as num?)?.toDouble() ?? 0.0;
        final actual = (ahorro['montoActual'] as num?)?.toDouble() ?? 0.0;
        final progreso = objetivo > 0 ? (actual / objetivo * 100) : 0.0;
        
        return {
          'descripcion': ahorro['nombre'] ?? ahorro['descripcion'] ?? '',
          'montoObjetivo': objetivo,
          'montoActual': actual,
          'porcentajeProgreso': progreso,
          'montoFaltante': objetivo - actual,
          'fechaObjetivo': _formatearFecha(ahorro['fechaObjetivo']),
          'estado': ahorro['estado'] ?? 'En progreso',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene y normaliza las cuentas
  static Future<List<Map<String, dynamic>>> _obtenerCuentas() async {
    try {
      final cuentasSnapshot = await _cuentasService.obtenerCuentas().first;
      return cuentasSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'banco': data['banco'] ?? data['nombreBanco'] ?? '',
          'numero': data['numeroCuenta'] ?? '',
          'tipo': data['tipo'] ?? data['tipoCuenta'] ?? '',
          'alias': data['alias'] ?? '',
          'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Formatea las fechas de manera consistente
  static DateTime _formatearFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    } else if (fecha is DateTime) {
      return fecha;
    } else if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}