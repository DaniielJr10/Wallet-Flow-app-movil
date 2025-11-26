/// SERVICIO DE PERSISTENCIA
/// Encapsula la lógica de SharedPreferences para guardar y recuperar
/// las notas del almacenamiento local del dispositivo.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServicioNotas {
  static const String _key = 'notes';

  Future<List<Map<String, dynamic>>> cargarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    
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

  Future<void> guardarNotas(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = notes.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_key, raw);
  }
}