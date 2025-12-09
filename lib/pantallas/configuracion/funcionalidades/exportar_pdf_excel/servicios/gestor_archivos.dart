/**
 * SERVICIO: Gestión de archivos
 * 
 * Maneja el guardado, compartido y descarga de archivos
 * tanto para plataformas móviles como web
 */

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../../../../util/web_downloader.dart';

class GestorArchivos {
  /// Guarda y comparte un archivo según la plataforma
  static Future<void> guardarYCompartir({
    required Uint8List bytes,
    required String nombreArchivo,
    required String extension,
    String? textoCompartir,
  }) async {
    if (kIsWeb) {
      await _descargarEnWeb(bytes, nombreArchivo, extension);
    } else {
      await _compartirEnMovil(bytes, nombreArchivo, extension, textoCompartir);
    }
  }

  /// Descarga directa para navegadores web
  static Future<void> _descargarEnWeb(
    Uint8List bytes,
    String nombreArchivo,
    String extension,
  ) async {
    final mimeType = _obtenerMimeType(extension);
    final nombreCompleto = '$nombreArchivo.$extension';
    
    downloadBytesAsFile(bytes, nombreCompleto, mimeType);
  }

  /// Comparte archivo en plataformas móviles
  static Future<void> _compartirEnMovil(
    Uint8List bytes,
    String nombreArchivo,
    String extension,
    String? textoCompartir,
  ) async {
    try {
      final dir = await _obtenerDirectorioTemporal();
      final nombreCompleto = '$nombreArchivo.$extension';
      final archivo = File('${dir.path}/$nombreCompleto');
      
      await archivo.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(archivo.path)],
        text: textoCompartir ?? 'Exportación desde Wallet Flow',
        subject: 'Datos Financieros - Wallet Flow',
      );
    } catch (e) {
      throw Exception('Error al compartir archivo: $e');
    }
  }

  /// Obtiene el directorio temporal de manera segura
  static Future<Directory> _obtenerDirectorioTemporal() async {
    try {
      return await getTemporaryDirectory();
    } on MissingPluginException {
      return Directory.systemTemp;
    } catch (e) {
      return Directory.systemTemp;
    }
  }

  /// Obtiene el tipo MIME según la extensión
  static String _obtenerMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'xlsx':
      case 'xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  /// Genera un nombre de archivo único con timestamp
  static String generarNombreArchivo({
    String prefijo = 'walletflow_export',
    String? sufijo,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sufijoFinal = sufijo != null ? '_$sufijo' : '';
    return '${prefijo}${sufijoFinal}_$timestamp';
  }

  /// Valida si el nombre de archivo es válido
  static bool nombreArchivoValido(String nombre) {
    // Caracteres no permitidos en nombres de archivo
    final caracteresInvalidos = RegExp(r'[<>:"/\\|?*]');
    return !caracteresInvalidos.hasMatch(nombre) && nombre.isNotEmpty;
  }

  /// Limpia un nombre de archivo de caracteres no válidos
  static String limpiarNombreArchivo(String nombre) {
    final caracteresInvalidos = RegExp(r'[<>:"/\\|?*]');
    return nombre.replaceAll(caracteresInvalidos, '_').trim();
  }
}