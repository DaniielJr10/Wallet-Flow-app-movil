/**
 * FUNCIONALIDAD: Exportación de datos
 * 
 * Este archivo maneja toda la funcionalidad relacionada con la exportación
 * de datos del usuario en diferentes formatos:
 * - Exportación a PDF con tablas formateadas
 * - Exportación a Excel (XLSX) con hojas separadas
 * - Gestión de archivos y compartir en diferentes plataformas
 * - Recopilación de datos de todos los servicios (ingresos, gastos, deudas, etc.)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importar servicios necesarios
import '../../../firebase/servicios/ingresoService/ingresos_servicio.dart';
import '../../../firebase/servicios/gastoService/gastos_servicio.dart';
import '../../../firebase/servicios/DeudaService/deudas_servicio.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../util/web_downloader.dart';

class ConfiguracionExportar {
  // Servicios para obtener datos
  static final IngresosServicio _ingresosService = IngresosServicio();
  static final GastosServicio _gastosService = GastosServicio();
  static final DeudasServicio _deudasService = DeudasServicio();
  static final AhorrosServicio _ahorrosService = AhorrosServicio();
  static final CuentasServicio _cuentasService = CuentasServicio();

  /// Muestra el modal de opciones de exportación
  static void mostrarOpcionesExportacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar a PDF'),
              onTap: () async {
                Navigator.pop(context);
                await exportarAPdf(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar a Excel (XLSX)'),
              onTap: () async {
                Navigator.pop(context);
                await exportarAExcel(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Exporta todos los datos a PDF
  static Future<void> exportarAPdf(BuildContext context) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando PDF...')),
      );

      // Obtener datos de todos los servicios
      final datosCompletos = await _obtenerTodosLosDatos();

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Wallet Flow - Exportación de Datos')),
            pw.SizedBox(height: 8),
            pw.Text('Fecha: ${DateTime.now()}'),
            pw.SizedBox(height: 12),

            // Tabla de Ingresos
            if (datosCompletos.ingresos.isNotEmpty) ...[
              pw.Text('Ingresos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Descripción', 'Categoría', 'Monto', 'Fecha'],
                data: datosCompletos.ingresos.map((i) => [
                  i['descripcion'] ?? '',
                  i['categoria'] ?? '',
                  (i['monto'] as num?)?.toStringAsFixed(2) ?? '0.00',
                  i['fecha'].toString(),
                ]).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Tabla de Gastos
            if (datosCompletos.gastos.isNotEmpty) ...[
              pw.Text('Gastos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Descripción', 'Categoría', 'Monto', 'Fecha'],
                data: datosCompletos.gastos.map((g) => [
                  g['nombre'] ?? '',
                  g['categoria'] ?? '',
                  (g['monto'] as double).toStringAsFixed(2),
                  g['fecha'].toString(),
                ]).toList(),
              ),
              pw.SizedBox(height: 12),
            ],
            
            // Tabla de Deudas
            if (datosCompletos.deudas.isNotEmpty) ...[
              pw.Text('Deudas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Acreedor', 'Monto Total', 'Monto Pagado', 'Fecha Vencimiento', 'Estado'],
                data: datosCompletos.deudas.map((d) => [
                  d['acreedor'] ?? '',
                  (d['montoTotal'] as num?)?.toStringAsFixed(2) ?? '0.00',
                  (d['montoPagado'] as num?)?.toStringAsFixed(2) ?? '0.00',
                  d['fechaVencimiento'].toString(),
                  d['estado'] ?? '',
                ]).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Tabla de Ahorros
            if (datosCompletos.ahorros.isNotEmpty) ...[
              pw.Text('Ahorros', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Descripción', 'Objetivo', 'Actual', 'Fecha Objetivo', 'Estado'],
                data: datosCompletos.ahorros.map((a) => [
                  a['descripcion'] ?? '',
                  (a['montoObjetivo'] as num?)?.toStringAsFixed(2) ?? '0.00',
                  (a['montoActual'] as num?)?.toStringAsFixed(2) ?? '0.00',
                  a['fechaObjetivo'].toString(),
                  a['estado'] ?? '',
                ]).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Tabla de Cuentas
            if (datosCompletos.cuentas.isNotEmpty) ...[
              pw.Text('Cuentas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Banco', 'Número', 'Tipo', 'Alias', 'Saldo'],
                data: datosCompletos.cuentas.map((c) => [
                  c['banco'] ?? '',
                  c['numero'] ?? '',
                  c['tipo'] ?? '',
                  c['alias'] ?? '',
                  (c['saldo'] as num?)?.toStringAsFixed(2) ?? '0.00',
                ]).toList(),
              ),
              pw.SizedBox(height: 12),
            ],
          ],
        ),
      );

      // Guardar y compartir archivo
      final bytes = await doc.save();
      await _guardarArchivo(context, bytes, 'pdf');
      
    } catch (e) {
      debugPrint('Error exportando a PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Exporta todos los datos a Excel
  static Future<void> exportarAExcel(BuildContext context) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando Excel...')),
      );

      // Obtener datos de todos los servicios
      final datosCompletos = await _obtenerTodosLosDatos();

      final excel = Excel.createExcel();
      
      // Hoja de Ingresos
      var ingresosSheet = excel['Ingresos'];
      ingresosSheet.appendRow(['Descripción', 'Categoría', 'Monto', 'Fecha']);
      for (final i in datosCompletos.ingresos) {
        ingresosSheet.appendRow([
          i['descripcion'] ?? '',
          i['categoria'] ?? '',
          (i['monto'] as num?)?.toStringAsFixed(2) ?? '0.00',
          i['fecha'].toString(),
        ]);
      }

      // Hoja de Gastos
      var gastosSheet = excel['Gastos'];
      gastosSheet.appendRow(['Descripción', 'Categoría', 'Monto', 'Fecha']);
      for (final g in datosCompletos.gastos) {
        gastosSheet.appendRow([
          g['nombre'] ?? '',
          g['categoria'] ?? '',
          (g['monto'] as num?)?.toStringAsFixed(2) ?? '0.00',
          g['fecha'].toString(),
        ]);
      }

      // Hoja de Ahorros
      var ahorrosSheet = excel['Ahorros'];
      ahorrosSheet.appendRow(['Nombre', 'Objetivo', 'Actual', 'Fecha Objetivo']);
      for (final a in datosCompletos.ahorros) {
        ahorrosSheet.appendRow([
          a['descripcion'] ?? '',
          (a['montoObjetivo'] as num?)?.toStringAsFixed(2) ?? '0.00',
          (a['montoActual'] as num?)?.toStringAsFixed(2) ?? '0.00',
          a['fechaObjetivo'].toString(),
        ]);
      }

      // Hoja de Deudas
      var deudasSheet = excel['Deudas'];
      deudasSheet.appendRow(['Acreedor', 'Total', 'Estado']);
      for (final d in datosCompletos.deudas) {
        deudasSheet.appendRow([
          d['acreedor'] ?? '',
          (d['montoTotal'] as num?)?.toStringAsFixed(2) ?? '0.00',
          d['estado'] ?? '',
        ]);
      }

      // Hoja de Cuentas
      var cuentasSheet = excel['Cuentas'];
      cuentasSheet.appendRow(['Banco', 'Número', 'Tipo', 'Alias', 'Saldo']);
      for (final c in datosCompletos.cuentas) {
        cuentasSheet.appendRow([
          c['banco'] ?? '',
          c['numero'] ?? '',
          c['tipo'] ?? '',
          c['alias'] ?? '',
          (c['saldo'] as num?)?.toStringAsFixed(2) ?? '0.00',
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('No se pudo generar el archivo Excel');
      
      await _guardarArchivo(context, Uint8List.fromList(bytes), 'xlsx');

    } catch (e) {
      debugPrint('Error exportando a Excel: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Obtiene directorio temporal de manera segura
  static Future<Directory> _getTempDirectory() async {
    try {
      return await getTemporaryDirectory();
    } on MissingPluginException {
      return Directory.systemTemp;
    } catch (e) {
      return Directory.systemTemp;
    }
  }

  /// Guarda y comparte el archivo generado
  static Future<void> _guardarArchivo(BuildContext context, Uint8List bytes, String ext) async {
    if (kIsWeb) {
      // Para web: descarga directa
      downloadBytesAsFile(
        bytes, 
        'walletflow_export_${DateTime.now().millisecondsSinceEpoch}.$ext', 
        ext == 'pdf' ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo descargado.')),
        );
      }
    } else {
      // Para móviles: guardar y compartir
      final dir = await _getTempDirectory();
      final file = File('${dir.path}/walletflow_export_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await file.writeAsBytes(bytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo generado. Compartiendo...')),
        );
        await Share.shareFiles([file.path], text: 'Exportación Wallet Flow');
      }
    }
  }

  /// Obtiene todos los datos de los servicios de manera centralizada
  static Future<_DatosCompletos> _obtenerTodosLosDatos() async {
    // Obtener ingresos (List<Map>)
    final ingresos = await _ingresosService.obtenerIngresos().first;
    
    // Obtener gastos (QuerySnapshot)
    final gastosSnapshot = await _gastosService.obtenerGastos().first;
    final gastos = gastosSnapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {
        'id': d.id,
        'nombre': data['descripcion'] ?? data['nombre'] ?? '',
        'monto': (data['monto'] as num?)?.toDouble() ?? 0.0,
        'fecha': data['fecha'] is Timestamp 
            ? (data['fecha'] as Timestamp).toDate() 
            : data['fecha'],
        'categoria': data['categoria'] ?? '',
      };
    }).toList();

    // Obtener deudas (List<Map>)
    final deudasRaw = await _deudasService.obtenerDeudasStream().first;
    final deudas = deudasRaw.map((data) {
      return {
        'acreedor': data['nombreAcreedor'] ?? '',
        'montoTotal': (data['montoTotal'] as num?)?.toDouble() ?? 0.0,
        'montoPagado': (data['montoPagado'] as num?)?.toDouble() ?? 0.0,
        'fechaVencimiento': data['fechaVencimiento'] is Timestamp 
            ? (data['fechaVencimiento'] as Timestamp).toDate() 
            : data['fechaVencimiento'],
        'estado': data['estado'] ?? '',
      };
    }).toList();

    // Obtener ahorros (List<Map>)
    final ahorrosRaw = await _ahorrosService.obtenerMetasAhorro().first;
    final ahorros = ahorrosRaw.map((data) {
      return {
        'descripcion': data['nombre'] ?? data['descripcion'] ?? '',
        'montoObjetivo': (data['montoObjetivo'] as num?)?.toDouble() ?? 0.0,
        'montoActual': (data['montoActual'] as num?)?.toDouble() ?? 0.0,
        'fechaObjetivo': data['fechaObjetivo'] is Timestamp 
            ? (data['fechaObjetivo'] as Timestamp).toDate() 
            : data['fechaObjetivo'],
        'estado': data['estado'] ?? '',
      };
    }).toList();

    // Obtener cuentas (QuerySnapshot)
    final cuentasSnapshot = await _cuentasService.obtenerCuentas().first;
    final cuentas = cuentasSnapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {
        'id': d.id,
        'banco': data['banco'] ?? data['nombreBanco'] ?? '',
        'numero': data['numeroCuenta'] ?? '',
        'tipo': data['tipo'] ?? data['tipoCuenta'] ?? '',
        'alias': data['alias'] ?? '',
        'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    return _DatosCompletos(
      ingresos: ingresos,
      gastos: gastos,
      deudas: deudas,
      ahorros: ahorros,
      cuentas: cuentas,
    );
  }
}

/// Clase helper para organizar todos los datos obtenidos
class _DatosCompletos {
  final List<Map<String, dynamic>> ingresos;
  final List<Map<String, dynamic>> gastos;
  final List<Map<String, dynamic>> deudas;
  final List<Map<String, dynamic>> ahorros;
  final List<Map<String, dynamic>> cuentas;

  _DatosCompletos({
    required this.ingresos,
    required this.gastos,
    required this.deudas,
    required this.ahorros,
    required this.cuentas,
  });
}