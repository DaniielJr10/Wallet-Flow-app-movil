import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TasasServicio {
  static const String _cacheKey = 'conversor_cached_rates';

  /// Intenta obtener las tasas más recientes desde exchangerate.host
  /// Devuelve un map de tasas relativo a la base solicitada (por defecto USD)
  static Future<Map<String, double>?> fetchLatestRates(
      {String base = 'USD', required List<String> symbols}) async {
    try {
      final symbolsParam = symbols.join(',');
      final uri = Uri.parse('https://api.exchangerate.host/latest?base=$base&symbols=$symbolsParam');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final Map<String, dynamic> body = json.decode(resp.body) as Map<String, dynamic>;
      final Map<String, dynamic>? rates = body['rates'] as Map<String, dynamic>?;
      if (rates == null) return null;

      final Map<String, double> out = {};
      // Incluir la base con valor 1.0
      out[base] = 1.0;
      rates.forEach((k, v) {
        if (v is num) out[k] = v.toDouble();
      });

      // Guardar en caché junto con la fecha
      final cache = {'base': base, 'date': body['date'] ?? DateTime.now().toIso8601String(), 'rates': out};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(cache));

      return out;
    } catch (_) {
      return null;
    }
  }

  /// Carga tasas guardadas en caché. Retorna null si no hay nada.
  static Future<Map<String, dynamic>?> loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_cacheKey);
    if (s == null) return null;
    try {
      final Map<String, dynamic> data = json.decode(s) as Map<String, dynamic>;
      final Map<String, dynamic>? rates = Map<String, dynamic>.from(data['rates'] ?? {});
      return {'base': data['base'], 'date': data['date'], 'rates': rates};
    } catch (_) {
      return null;
    }
  }

  /// Borra la caché de tasas
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
