/**
 * COORDINADOR PRINCIPAL: Exportación de datos
 * 
 * Este es el archivo principal que coordina todas las funcionalidades
 * de exportación utilizando los servicios especializados.
 * 
 * Funcionalidades:
 * - Coordinación entre todos los servicios
 * - Manejo de errores centralizado
 * - Interfaz simplificada para la UI
 * - Validaciones y mensajes de usuario
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Importar modelos
import 'modelos/datos_exportacion.dart';

// Importar servicios
import 'servicios/recopilador_datos.dart';
import 'servicios/exportador_pdf.dart';
import 'servicios/exportador_excel.dart';
import 'servicios/gestor_archivos.dart';

// Importar widgets
import 'widgets/widgets_exportacion.dart';

class CoordinadorExportacion {
  /// Punto de entrada principal para mostrar las opciones de exportación
  static void mostrarOpcionesExportacion(BuildContext context) {
    WidgetsExportacion.mostrarOpcionesExportacion(
      context,
      onExportarPdf: () => _exportarAPdf(context),
      onExportarExcel: () => _exportarAExcel(context),
    );
  }

  /// Coordina la exportación a PDF
  static Future<void> _exportarAPdf(BuildContext context) async {
    try {
      // Mostrar progreso
      WidgetsExportacion.mostrarProgreso(context, 'Generando PDF...');

      // Obtener datos
      final datos = await _obtenerYValidarDatos();
      
      if (!datos.tieneDatos) {
        WidgetsExportacion.ocultarProgreso(context);
        WidgetsExportacion.mostrarError(context, 'No hay datos para exportar');
        return;
      }

      // Generar PDF
      final bytes = await ExportadorPdf.generarPdf(datos);
      
      // Guardar y compartir
      final nombreArchivo = GestorArchivos.generarNombreArchivo(sufijo: 'datos');
      
      await GestorArchivos.guardarYCompartir(
        bytes: bytes,
        nombreArchivo: nombreArchivo,
        extension: 'pdf',
        textoCompartir: 'Reporte financiero generado desde Wallet Flow',
      );

      // Ocultar progreso y mostrar éxito
      WidgetsExportacion.ocultarProgreso(context);
      WidgetsExportacion.mostrarExito(
        context,
        kIsWeb 
          ? 'PDF descargado exitosamente' 
          : 'PDF generado y compartido exitosamente',
      );

    } catch (e) {
      // Manejar errores
      WidgetsExportacion.ocultarProgreso(context);
      _manejarError(context, e, 'Error al generar PDF');
    }
  }

  /// Coordina la exportación a Excel
  static Future<void> _exportarAExcel(BuildContext context) async {
    try {
      // Mostrar progreso
      WidgetsExportacion.mostrarProgreso(context, 'Generando Excel...');

      // Obtener datos
      final datos = await _obtenerYValidarDatos();
      
      if (!datos.tieneDatos) {
        WidgetsExportacion.ocultarProgreso(context);
        WidgetsExportacion.mostrarError(context, 'No hay datos para exportar');
        return;
      }

      // Generar Excel
      final bytes = await ExportadorExcel.generarExcel(datos);
      
      // Guardar y compartir
      final nombreArchivo = GestorArchivos.generarNombreArchivo(sufijo: 'datos');
      
      await GestorArchivos.guardarYCompartir(
        bytes: bytes,
        nombreArchivo: nombreArchivo,
        extension: 'xlsx',
        textoCompartir: 'Reporte financiero generado desde Wallet Flow',
      );

      // Ocultar progreso y mostrar éxito
      WidgetsExportacion.ocultarProgreso(context);
      WidgetsExportacion.mostrarExito(
        context,
        kIsWeb 
          ? 'Excel descargado exitosamente' 
          : 'Excel generado y compartido exitosamente',
      );

    } catch (e) {
      // Manejar errores
      WidgetsExportacion.ocultarProgreso(context);
      _manejarError(context, e, 'Error al generar Excel');
    }
  }

  /// Obtiene y valida los datos para exportación
  static Future<DatosExportacion> _obtenerYValidarDatos() async {
    try {
      final datos = await RecopiladorDatos.obtenerTodosLosDatos();
      return datos;
    } catch (e) {
      throw Exception('Error al obtener datos: $e');
    }
  }

  /// Maneja los errores de manera centralizada
  static void _manejarError(BuildContext context, dynamic error, String mensajeGenerico) {
    String mensajeError;
    
    if (error is Exception) {
      mensajeError = error.toString().replaceAll('Exception: ', '');
    } else {
      mensajeError = error.toString();
    }

    // Log del error para debugging
    debugPrint('Error de exportación: $mensajeError');
    
    // Mostrar mensaje amigable al usuario
    String mensajeFinal;
    if (mensajeError.toLowerCase().contains('conexión') ||
        mensajeError.toLowerCase().contains('internet') ||
        mensajeError.toLowerCase().contains('network')) {
      mensajeFinal = 'Error de conexión. Verifica tu internet e inténtalo nuevamente.';
    } else if (mensajeError.toLowerCase().contains('permisos') ||
               mensajeError.toLowerCase().contains('permission')) {
      mensajeFinal = 'Error de permisos. Verifica los permisos de almacenamiento.';
    } else if (mensajeError.toLowerCase().contains('espacio') ||
               mensajeError.toLowerCase().contains('storage') ||
               mensajeError.toLowerCase().contains('disk')) {
      mensajeFinal = 'Espacio insuficiente en el dispositivo.';
    } else {
      mensajeFinal = '$mensajeGenerico: ${mensajeError.length > 100 
        ? '${mensajeError.substring(0, 100)}...'
        : mensajeError}';
    }

    WidgetsExportacion.mostrarError(context, mensajeFinal);
  }
}

/// Enumeraciones para mayor claridad
enum TipoDatos {
  ingresos,
  gastos,
  deudas,
  ahorros,
  cuentas,
}

enum FormatoExportacion {
  pdf,
  excel,
}