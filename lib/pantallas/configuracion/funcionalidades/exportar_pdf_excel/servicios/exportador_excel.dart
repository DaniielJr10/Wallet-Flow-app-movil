/**
 * SERVICIO: Exportación a Excel
 * 
 * Maneja toda la lógica de generación de archivos Excel con múltiples hojas
 */

import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import '../modelos/datos_exportacion.dart';

class ExportadorExcel {
  /// Genera un archivo Excel con todas las hojas de datos
  static Future<Uint8List> generarExcel(DatosExportacion datos) async {
    final excel = Excel.createExcel();
    
    // Eliminar la hoja por defecto
    excel.delete('Sheet1');

    // Crear hojas según los datos disponibles
    if (datos.ingresos.isNotEmpty) {
      _crearHojaIngresos(excel, datos.ingresos);
    }
    
    if (datos.gastos.isNotEmpty) {
      _crearHojaGastos(excel, datos.gastos);
    }
    
    if (datos.deudas.isNotEmpty) {
      _crearHojaDeudas(excel, datos.deudas);
    }
    
    if (datos.ahorros.isNotEmpty) {
      _crearHojaAhorros(excel, datos.ahorros);
    }
    
    if (datos.cuentas.isNotEmpty) {
      _crearHojaCuentas(excel, datos.cuentas);
    }

    // Crear hoja de resumen
    _crearHojaResumen(excel, datos);

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('No se pudo generar el archivo Excel');
    }
    
    return Uint8List.fromList(bytes);
  }

  /// Crea la hoja de ingresos
  static void _crearHojaIngresos(Excel excel, List<Map<String, dynamic>> ingresos) {
    final sheet = excel['💰 Ingresos'];
    
    // Encabezados
    final headers = ['Descripción', 'Categoría', 'Monto', 'Fecha'];
    _agregarEncabezados(sheet, headers);
    
    // Datos
    for (final ingreso in ingresos) {
      sheet.appendRow([
        ingreso['descripcion'] ?? '',
        ingreso['categoria'] ?? '',
        (ingreso['monto'] as double?)?.toDouble() ?? 0.0,
        _formatearFecha(ingreso['fecha']),
      ]);
    }
    
    // Total
    final totalIngresos = ingresos
        .map((i) => (i['monto'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    
    sheet.appendRow(['', '', '', '']);
    sheet.appendRow(['TOTAL:', '', totalIngresos, '']);
    
    _formatearHoja(sheet, headers.length);
  }

  /// Crea la hoja de gastos
  static void _crearHojaGastos(Excel excel, List<Map<String, dynamic>> gastos) {
    final sheet = excel['💳 Gastos'];
    
    // Encabezados
    final headers = ['Descripción', 'Categoría', 'Monto', 'Fecha'];
    _agregarEncabezados(sheet, headers);
    
    // Datos
    for (final gasto in gastos) {
      sheet.appendRow([
        gasto['descripcion'] ?? '',
        gasto['categoria'] ?? '',
        (gasto['monto'] as double?)?.toDouble() ?? 0.0,
        _formatearFecha(gasto['fecha']),
      ]);
    }
    
    // Total
    final totalGastos = gastos
        .map((g) => (g['monto'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    
    sheet.appendRow(['', '', '', '']);
    sheet.appendRow(['TOTAL:', '', totalGastos, '']);
    
    _formatearHoja(sheet, headers.length);
  }

  /// Crea la hoja de deudas
  static void _crearHojaDeudas(Excel excel, List<Map<String, dynamic>> deudas) {
    final sheet = excel['📋 Deudas'];
    
    // Encabezados
    final headers = ['Acreedor', 'Monto Total', 'Monto Pagado', 'Monto Restante', 'Fecha Vencimiento', 'Estado'];
    _agregarEncabezados(sheet, headers);
    
    // Datos
    for (final deuda in deudas) {
      sheet.appendRow([
        deuda['acreedor'] ?? '',
        (deuda['montoTotal'] as double?)?.toDouble() ?? 0.0,
        (deuda['montoPagado'] as double?)?.toDouble() ?? 0.0,
        (deuda['montoRestante'] as double?)?.toDouble() ?? 0.0,
        _formatearFecha(deuda['fechaVencimiento']),
        deuda['estado'] ?? '',
      ]);
    }
    
    // Totales
    final totalDeudas = deudas
        .map((d) => (d['montoTotal'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    final totalPagado = deudas
        .map((d) => (d['montoPagado'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    final totalRestante = deudas
        .map((d) => (d['montoRestante'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    
    sheet.appendRow(['', '', '', '', '', '']);
    sheet.appendRow(['TOTALES:', totalDeudas, totalPagado, totalRestante, '', '']);
    
    _formatearHoja(sheet, headers.length);
  }

  /// Crea la hoja de ahorros
  static void _crearHojaAhorros(Excel excel, List<Map<String, dynamic>> ahorros) {
    final sheet = excel['🏦 Ahorros'];
    
    // Encabezados
    final headers = ['Descripción', 'Objetivo', 'Actual', 'Progreso (%)', 'Faltante', 'Fecha Objetivo', 'Estado'];
    _agregarEncabezados(sheet, headers);
    
    // Datos
    for (final ahorro in ahorros) {
      sheet.appendRow([
        ahorro['descripcion'] ?? '',
        (ahorro['montoObjetivo'] as double?)?.toDouble() ?? 0.0,
        (ahorro['montoActual'] as double?)?.toDouble() ?? 0.0,
        (ahorro['porcentajeProgreso'] as double?)?.toDouble() ?? 0.0,
        (ahorro['montoFaltante'] as double?)?.toDouble() ?? 0.0,
        _formatearFecha(ahorro['fechaObjetivo']),
        ahorro['estado'] ?? '',
      ]);
    }
    
    // Totales
    final totalObjetivo = ahorros
        .map((a) => (a['montoObjetivo'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    final totalActual = ahorros
        .map((a) => (a['montoActual'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    final progresoGeneral = totalObjetivo > 0 ? (totalActual / totalObjetivo * 100) : 0.0;
    
    sheet.appendRow(['', '', '', '', '', '', '']);
    sheet.appendRow(['TOTALES:', totalObjetivo, totalActual, progresoGeneral, totalObjetivo - totalActual, '', '']);
    
    _formatearHoja(sheet, headers.length);
  }

  /// Crea la hoja de cuentas
  static void _crearHojaCuentas(Excel excel, List<Map<String, dynamic>> cuentas) {
    final sheet = excel['🏧 Cuentas'];
    
    // Encabezados
    final headers = ['Banco', 'Número de Cuenta', 'Tipo', 'Alias', 'Saldo'];
    _agregarEncabezados(sheet, headers);
    
    // Datos
    for (final cuenta in cuentas) {
      sheet.appendRow([
        cuenta['banco'] ?? '',
        cuenta['numero'] ?? '',
        cuenta['tipo'] ?? '',
        cuenta['alias'] ?? '',
        (cuenta['saldo'] as double?)?.toDouble() ?? 0.0,
      ]);
    }
    
    // Total
    final totalSaldos = cuentas
        .map((c) => (c['saldo'] as double?) ?? 0.0)
        .fold(0.0, (sum, saldo) => sum + saldo);
    
    sheet.appendRow(['', '', '', '', '']);
    sheet.appendRow(['TOTAL SALDOS:', '', '', '', totalSaldos]);
    
    _formatearHoja(sheet, headers.length);
  }

  /// Crea la hoja de resumen
  static void _crearHojaResumen(Excel excel, DatosExportacion datos) {
    final sheet = excel['📊 Resumen'];
    
    // Título
    sheet.appendRow(['WALLET FLOW - RESUMEN FINANCIERO']);
    sheet.appendRow(['Fecha de generación: ${_formatearFecha(DateTime.now())}']);
    sheet.appendRow(['']);
    
    // Resumen por categorías
    sheet.appendRow(['RESUMEN POR CATEGORÍAS']);
    sheet.appendRow(['Categoría', 'Cantidad de Registros', 'Total (si aplica)']);
    
    // Ingresos
    final totalIngresos = datos.ingresos
        .map((i) => (i['monto'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    sheet.appendRow(['💰 Ingresos', datos.ingresos.length, totalIngresos]);
    
    // Gastos
    final totalGastos = datos.gastos
        .map((g) => (g['monto'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    sheet.appendRow(['💳 Gastos', datos.gastos.length, totalGastos]);
    
    // Balance
    final balance = totalIngresos - totalGastos;
    sheet.appendRow(['💰 Balance (Ingresos - Gastos)', '', balance]);
    
    // Deudas
    final totalDeudas = datos.deudas
        .map((d) => (d['montoRestante'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    sheet.appendRow(['📋 Deudas Pendientes', datos.deudas.length, totalDeudas]);
    
    // Ahorros
    final totalAhorros = datos.ahorros
        .map((a) => (a['montoActual'] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
    sheet.appendRow(['🏦 Ahorros Actuales', datos.ahorros.length, totalAhorros]);
    
    // Cuentas
    final totalCuentas = datos.cuentas
        .map((c) => (c['saldo'] as double?) ?? 0.0)
        .fold(0.0, (sum, saldo) => sum + saldo);
    sheet.appendRow(['🏧 Saldo Total en Cuentas', datos.cuentas.length, totalCuentas]);
    
    sheet.appendRow(['']);
    sheet.appendRow(['PATRIMONIO NETO ESTIMADO']);
    final patrimonioNeto = totalCuentas + totalAhorros - totalDeudas;
    sheet.appendRow(['Patrimonio Neto (Cuentas + Ahorros - Deudas)', '', patrimonioNeto]);
    
    _formatearHoja(sheet, 3);
  }

  /// Agrega los encabezados a una hoja
  static void _agregarEncabezados(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers);
  }

  /// Aplica formato básico a la hoja
  static void _formatearHoja(Sheet sheet, int numColumns) {
    // Aquí podrías agregar formato adicional si la librería lo soporta
    // Por ejemplo: ancho de columnas, formato de celdas, etc.
  }

  /// Formatea una fecha para Excel
  static String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
           '${fecha.month.toString().padLeft(2, '0')}/'
           '${fecha.year}';
  }
}