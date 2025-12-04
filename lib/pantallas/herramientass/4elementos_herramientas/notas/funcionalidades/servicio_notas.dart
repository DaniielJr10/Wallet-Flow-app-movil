/// SERVICIO DE PERSISTENCIA HÍBRIDO
/// Encapsula la lógica para usar Firebase Firestore como principal
/// y SharedPreferences como respaldo para compatibilidad y migración.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../firebase/servicios/NotasService/notas_servicio.dart';

class ServicioNotas {
  static const String _keyLocal = 'notes';
  static const String _keyMigrated = 'notes_migrated';
  
  final NotasServicio _notasFirebase = NotasServicio();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cargar notas usando Firebase como fuente principal
  Future<List<Map<String, dynamic>>> cargarNotas() async {
    try {
      // Verificar si el usuario está autenticado
      if (_auth.currentUser != null) {
        // Intentar migrar datos locales si no se ha hecho antes
        await _migrarDatosLocalesSiEsNecesario();
        
        // Obtener notas de Firebase
        final notasFirebase = await _notasFirebase.obtenerNotas();
        
        // Convertir a formato compatible con la UI actual
        return notasFirebase.map((nota) => nota.toLocal()).toList();
      } else {
        // Si no está autenticado, usar almacenamiento local
        return await _cargarNotasLocales();
      }
    } catch (e) {
      print('Error al cargar notas de Firebase, usando respaldo local: $e');
      return await _cargarNotasLocales();
    }
  }

  /// Guardar notas usando Firebase como destino principal
  Future<void> guardarNotas(List<Map<String, dynamic>> notes) async {
    try {
      if (_auth.currentUser != null) {
        // Guardar en Firebase
        await _guardarNotasFirebase(notes);
      } else {
        // Si no está autenticado, guardar localmente
        await _guardarNotasLocales(notes);
      }
    } catch (e) {
      print('Error al guardar en Firebase, guardando localmente: $e');
      await _guardarNotasLocales(notes);
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Cargar notas del almacenamiento local
  Future<List<Map<String, dynamic>>> _cargarNotasLocales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyLocal) ?? [];
    
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m;
      } catch (_) {
        // Recuperación de datos antiguos si no eran JSON válido
        return {"text": s, "date": DateTime.now().toIso8601String(), "tags": []};
      }
    }).toList();
  }

  /// Guardar notas en almacenamiento local
  Future<void> _guardarNotasLocales(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = notes.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_keyLocal, raw);
  }

  /// Guardar notas en Firebase
  Future<void> _guardarNotasFirebase(List<Map<String, dynamic>> notes) async {
    // Esta función maneja la sincronización completa
    // En una implementación real, sería mejor manejar operaciones individuales
    // Aquí se simplifica para mantener compatibilidad con la interfaz actual
    
    // Procesar cada nota del array local
    for (final notaLocal in notes) {
      try {
        // Si la nota no tiene ID, crear una nueva
        if (!notaLocal.containsKey('id') || notaLocal['id'] == null) {
          await _notasFirebase.crearNota(
            texto: notaLocal['text'] ?? notaLocal['texto'] ?? '',
            etiquetas: List<String>.from(notaLocal['tags'] ?? notaLocal['etiquetas'] ?? []),
            color: notaLocal['color'] ?? '#FFE082',
            esImportante: notaLocal['esImportante'] ?? false,
            categoria: notaLocal['categoria'],
          );
        }
      } catch (e) {
        print('Error al procesar nota para Firebase: $e');
      }
    }
  }

  /// Migrar datos locales a Firebase si es necesario
  Future<void> _migrarDatosLocalesSiEsNecesario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final yaMigrado = prefs.getBool(_keyMigrated) ?? false;
      
      if (yaMigrado) return;
      
      // Obtener datos locales
      final notasLocales = await _cargarNotasLocales();
      
      if (notasLocales.isNotEmpty) {
        print('Migrando ${notasLocales.length} notas locales a Firebase...');
        
        // Migrar cada nota
        for (final notaLocal in notasLocales) {
          try {
            await _notasFirebase.crearNota(
              texto: notaLocal['text'] ?? notaLocal['texto'] ?? '',
              etiquetas: List<String>.from(notaLocal['tags'] ?? notaLocal['etiquetas'] ?? []),
              color: notaLocal['color'] ?? '#FFE082',
              esImportante: notaLocal['esImportante'] ?? false,
              categoria: notaLocal['categoria'],
            );
          } catch (e) {
            print('Error migrando nota individual: $e');
          }
        }
        
        print('Migración completada.');
      }
      
      // Marcar como migrado
      await prefs.setBool(_keyMigrated, true);
      
    } catch (e) {
      print('Error durante migración: $e');
    }
  }
}