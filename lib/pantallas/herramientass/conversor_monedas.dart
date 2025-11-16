import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// shared_preferences removed: rates are fixed (no editing)

/// Conversor de monedas sin conexión (offline) con edición y persistencia
/// de tasas. Diseño cuidado para integrarse con la paleta verde de la app.
class ConversorMonedasScreen extends StatefulWidget {
  const ConversorMonedasScreen({super.key});

  @override
  State<ConversorMonedasScreen> createState() => _ConversorMonedasScreenState();
}

class _ConversorMonedasScreenState extends State<ConversorMonedasScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');

  List<String> currencies = ['USD', 'EUR', 'COP', 'GBP', 'JPY', 'CAD', 'AUD'];
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  String result = '';
  bool isLoading = false;

  // Tasas relativas a la base USD (valores por defecto).
  Map<String, double> rates = {
    'USD': 1.0,
    // Valores actualizados según tu captura
    'EUR': 0.8603,
    'COP': 3758.0,
    'GBP': 0.759,
    'JPY': 154.51,
    'CAD': 1.3996,
    'AUD': 1.53,
  };

  // Live mode indicator & last fetch info
  bool onlineMode = false;
  String lastUpdated = '';

  @override
  void initState() {
    super.initState();
    // Usamos las tasas fijas por defecto; no hay edición ni persistencia.
  }

  void _swap() {
    setState(() {
      final tmp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = tmp;
      result = '';
    });
  }

  Future<void> _convert() async {
    final String text = _amountController.text.trim();
    final double amount = double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      setState(() => result = 'Ingresa una cantidad válida.');
      return;
    }
    setState(() {
      isLoading = true;
      onlineMode = false;
      lastUpdated = '';
    });

    // Try to fetch live rate from exchangerate.host (no API key required)
    try {
      final uri = Uri.parse('https://api.exchangerate.host/latest?base=$fromCurrency&symbols=$toCurrency');
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body) as Map<String, dynamic>;
        final ratesMap = data['rates'] as Map<String, dynamic>?;
        if (ratesMap != null && ratesMap.containsKey(toCurrency)) {
          final num r = ratesMap[toCurrency] as num;
          final converted = amount * r.toDouble();
          final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
          setState(() {
            result = '${formatter.format(converted)} $toCurrency';
            onlineMode = true;
            lastUpdated = data['date'] ?? DateTime.now().toIso8601String();
            isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // ignore, we'll fallback to local rates
    }

    // Fallback: use local fixed rates
    final double? fromRate = rates[fromCurrency];
    final double? toRate = rates[toCurrency];
    await Future.delayed(const Duration(milliseconds: 120));
    if (fromRate == null || toRate == null) {
      setState(() {
        result = 'Falta la tasa para la moneda seleccionada.';
        isLoading = false;
      });
      return;
    }
    final converted = amount * (toRate / fromRate);
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    setState(() {
      result = '${formatter.format(converted)} $toCurrency';
      onlineMode = false;
      isLoading = false;
    });
  }

  // No hay diálogo de edición: las tasas son fijas en esta versión.

  String _labelFor(String code) {
    switch (code) {
      case 'USD':
        return 'Dólar (USD)';
      case 'EUR':
        return 'Euro (EUR)';
      case 'COP':
        return 'Peso colombiano (COP)';
      case 'GBP':
        return 'Libra (GBP)';
      case 'JPY':
        return 'Yen (JPY)';
      case 'CAD':
        return 'Dólar canadiense (CAD)';
      case 'AUD':
        return 'Dólar australiano (AUD)';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Icon(Icons.savings, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 8),
              const Text('Conversor de Monedas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              const SizedBox(height: 6),
              const Text('Convierte entre diferentes monedas de forma rápida y sencilla', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Ingresa la cantidad',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: border,
                        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.green.shade600, width: 2)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('De', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              InputDecorator(
                                decoration: InputDecoration(border: border, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: fromCurrency,
                                    isExpanded: true,
                                    items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(_labelFor(c)))).toList(),
                                    onChanged: (v) => setState(() { fromCurrency = v!; }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),
                        Column(
                          children: [
                            InkWell(
                              onTap: _swap,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(30)),
                                child: const Icon(Icons.swap_horiz, color: Color(0xFF10B981), size: 28),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('A', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              InputDecorator(
                                decoration: InputDecoration(border: border, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: toCurrency,
                                    isExpanded: true,
                                    items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(_labelFor(c)))).toList(),
                                    onChanged: (v) => setState(() { toCurrency = v!; }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: isLoading ? null : _convert,
                                            icon: const Icon(Icons.swap_vert, size: 20),
                                            label: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Text(isLoading ? 'Convirtiendo...' : 'Convertir', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // No hay edición de tasas: las tasas son las actuales fijas.
                                        SizedBox(width: 0, height: 0),
                                      ],
                                    ),

                    const SizedBox(height: 12),
                    if (result.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),
                          Text(result, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(onlineMode ? 'Modo: En línea' : 'Modo: Sin conexión', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('Tasa ${fromCurrency} → ${toCurrency}: ${(rates[toCurrency]! / rates[fromCurrency]!).toStringAsFixed(6)}', style: const TextStyle(color: Colors.black87)),
                                const SizedBox(height: 4),
                                if (onlineMode && lastUpdated.isNotEmpty)
                                  Text('Actualizado: $lastUpdated', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                if (!onlineMode)
                                  const Text('Base de referencia: USD', style: TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

