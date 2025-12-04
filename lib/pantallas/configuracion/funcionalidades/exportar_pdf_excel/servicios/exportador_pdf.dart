/**
 * SERVICIO: Exportación a PDF
 * 
 * Maneja toda la lógica de generación y formateo de documentos PDF
 */

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../modelos/datos_exportacion.dart';

class ExportadorPdf {
  /// Genera un documento PDF con todos los datos proporcionados
  static Future<Uint8List> generarPdf(DatosExportacion datos) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Encabezado del documento
          _construirEncabezado(),
          pw.SizedBox(height: 20),
          
          // Resumen de datos
          _construirResumen(datos),
          pw.SizedBox(height: 20),

          // Secciones de datos
          if (datos.ingresos.isNotEmpty) ...[
            _construirSeccionIngresos(datos.ingresos),
            pw.SizedBox(height: 16),
          ],
          
          if (datos.gastos.isNotEmpty) ...[
            _construirSeccionGastos(datos.gastos),
            pw.SizedBox(height: 16),
          ],
          
          if (datos.deudas.isNotEmpty) ...[
            _construirSeccionDeudas(datos.deudas),
            pw.SizedBox(height: 16),
          ],
          
          if (datos.ahorros.isNotEmpty) ...[
            _construirSeccionAhorros(datos.ahorros),
            pw.SizedBox(height: 16),
          ],
          
          if (datos.cuentas.isNotEmpty) ...[
            _construirSeccionCuentas(datos.cuentas),
          ],
        ],
      ),
    );

    return await doc.save();
  }

  /// Construye el encabezado del documento
  static pw.Widget _construirEncabezado() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Wallet Flow - Exportación de Datos Financieros',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Fecha de generación: ${_formatearFecha(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Construye un resumen de los datos
  static pw.Widget _construirResumen(DatosExportacion datos) {
    final resumen = datos.resumenDatos;
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen de Datos',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...resumen.entries.map((entry) => pw.Text(
            '${entry.key}: ${entry.value} registros',
            style: const pw.TextStyle(fontSize: 11),
          )),
        ],
      ),
    );
  }

  /// Construye la sección de ingresos
  static pw.Widget _construirSeccionIngresos(List<Map<String, dynamic>> ingresos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _construirTituloSeccion('💰 Ingresos'),
        pw.Table.fromTextArray(
          headers: ['Descripción', 'Categoría', 'Monto', 'Fecha'],
          data: ingresos.map((ingreso) => [
            ingreso['descripcion'] ?? '',
            ingreso['categoria'] ?? '',
            '\$${(ingreso['monto'] as double).toStringAsFixed(2)}',
            _formatearFecha(ingreso['fecha']),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.green100),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        _construirTotalSeccion(ingresos, 'Total Ingresos'),
      ],
    );
  }

  /// Construye la sección de gastos
  static pw.Widget _construirSeccionGastos(List<Map<String, dynamic>> gastos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _construirTituloSeccion('💳 Gastos'),
        pw.Table.fromTextArray(
          headers: ['Descripción', 'Categoría', 'Monto', 'Fecha'],
          data: gastos.map((gasto) => [
            gasto['descripcion'] ?? '',
            gasto['categoria'] ?? '',
            '\$${(gasto['monto'] as double).toStringAsFixed(2)}',
            _formatearFecha(gasto['fecha']),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.red100),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        _construirTotalSeccion(gastos, 'Total Gastos'),
      ],
    );
  }

  /// Construye la sección de deudas
  static pw.Widget _construirSeccionDeudas(List<Map<String, dynamic>> deudas) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _construirTituloSeccion('📋 Deudas'),
        pw.Table.fromTextArray(
          headers: ['Acreedor', 'Total', 'Pagado', 'Restante', 'Vencimiento', 'Estado'],
          data: deudas.map((deuda) => [
            deuda['acreedor'] ?? '',
            '\$${(deuda['montoTotal'] as double).toStringAsFixed(2)}',
            '\$${(deuda['montoPagado'] as double).toStringAsFixed(2)}',
            '\$${(deuda['montoRestante'] as double).toStringAsFixed(2)}',
            _formatearFecha(deuda['fechaVencimiento']),
            deuda['estado'] ?? '',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.orange100),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        _construirTotalSeccion(deudas, 'Total Deudas', campo: 'montoRestante'),
      ],
    );
  }

  /// Construye la sección de ahorros
  static pw.Widget _construirSeccionAhorros(List<Map<String, dynamic>> ahorros) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _construirTituloSeccion('🏦 Ahorros'),
        pw.Table.fromTextArray(
          headers: ['Descripción', 'Objetivo', 'Actual', 'Progreso', 'Fecha Objetivo'],
          data: ahorros.map((ahorro) => [
            ahorro['descripcion'] ?? '',
            '\$${(ahorro['montoObjetivo'] as double).toStringAsFixed(2)}',
            '\$${(ahorro['montoActual'] as double).toStringAsFixed(2)}',
            '${(ahorro['porcentajeProgreso'] as double).toStringAsFixed(1)}%',
            _formatearFecha(ahorro['fechaObjetivo']),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue100),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        _construirTotalSeccion(ahorros, 'Total Ahorrado', campo: 'montoActual'),
      ],
    );
  }

  /// Construye la sección de cuentas
  static pw.Widget _construirSeccionCuentas(List<Map<String, dynamic>> cuentas) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _construirTituloSeccion('🏧 Cuentas Bancarias'),
        pw.Table.fromTextArray(
          headers: ['Banco', 'Número', 'Tipo', 'Alias', 'Saldo'],
          data: cuentas.map((cuenta) => [
            cuenta['banco'] ?? '',
            cuenta['numero'] ?? '',
            cuenta['tipo'] ?? '',
            cuenta['alias'] ?? '',
            '\$${(cuenta['saldo'] as double).toStringAsFixed(2)}',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.purple100),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        _construirTotalSeccion(cuentas, 'Saldo Total', campo: 'saldo'),
      ],
    );
  }

  /// Construye el título de una sección
  static pw.Widget _construirTituloSeccion(String titulo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// Construye el total de una sección
  static pw.Widget _construirTotalSeccion(
    List<Map<String, dynamic>> datos,
    String etiqueta, {
    String campo = 'monto',
  }) {
    final total = datos
        .map((item) => (item[campo] as double?) ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$etiqueta:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '\$${total.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Formatea una fecha para mostrar en el PDF
  static String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
           '${fecha.month.toString().padLeft(2, '0')}/'
           '${fecha.year}';
  }
}