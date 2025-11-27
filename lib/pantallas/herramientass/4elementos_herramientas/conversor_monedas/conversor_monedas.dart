/// ORQUESTADOR DEL CONVERSOR
/// Gestiona el estado de la conversión (cargando, resultado, modo online),
/// realiza las llamadas HTTP y coordina los componentes visuales.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// Importaciones modularizadas
import 'funcionalidades/utils_conversor.dart';
import 'funcionalidades/app_bar_conversor.dart';
import 'funcionalidades/tasas_servicio.dart';
import 'funcionalidades/header_conversor.dart';
import 'funcionalidades/tarjeta_conversor.dart';
import 'funcionalidades/resultado_conversor.dart';

class ConversorMonedasScreen extends StatefulWidget {
  const ConversorMonedasScreen({super.key});

  @override
  State<ConversorMonedasScreen> createState() => _ConversorMonedasScreenState();
}

class _ConversorMonedasScreenState extends State<ConversorMonedasScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');

  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  String result = '';
  bool isLoading = false;
  bool onlineMode = false;
  String lastUpdated = '';

  // Tasas locales (se usan como fallback)
  Map<String, double> _localRates = Map<String, double>.from(UtilsConversor.ratesBase);

  @override
  void initState() {
    super.initState();
    // Cargar tasas en caché al iniciar
    TasasServicio.loadCachedRates().then((cached) {
      if (cached != null && cached['rates'] != null) {
        final Map<String, dynamic> ratesDyn = Map<String, dynamic>.from(cached['rates']);
        setState(() {
          _localRates = ratesDyn.map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0));
          lastUpdated = cached['date'] ?? '';
        });
      }
    });
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

    // 1. Intentar conversión ONLINE
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
      // Fallo online, continuamos con offline
    }

    // 2. Fallback OFFLINE
    final double? fromRate = _localRates[fromCurrency];
    final double? toRate = _localRates[toCurrency];
    
    // Simular pequeño delay para UX
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

  Future<void> _refreshRates() async {
    setState(() => isLoading = true);
    final latest = await TasasServicio.fetchLatestRates(base: 'USD', symbols: UtilsConversor.currencies);
    await Future.delayed(const Duration(milliseconds: 300));
    if (latest != null && latest.isNotEmpty) {
      setState(() {
        _localRates = latest;
        onlineMode = true;
        lastUpdated = DateTime.now().toIso8601String();
        isLoading = false;
        result = 'Tasas actualizadas.';
      });
    } else {
      setState(() {
        isLoading = false;
        result = 'No se pudieron actualizar las tasas.';
      });
    }
    // Limpiar mensaje después de 2s
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => result = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtilsConversor.colorFondo,
      appBar: AppBarConversor(onRefresh: _refreshRates),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const HeaderConversor(),
              const SizedBox(height: 20),
              
              TarjetaConversor(
                amountController: _amountController,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                isLoading: isLoading,
                onFromChanged: (v) => setState(() => fromCurrency = v!),
                onToChanged: (v) => setState(() => toCurrency = v!),
                onSwap: _swap,
                onConvert: _convert,
              ),

              const SizedBox(height: 12),

              ResultadoConversor(
                result: result,
                onlineMode: onlineMode,
                lastUpdated: lastUpdated,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                rates: _localRates,
              ),
            ],
          ),
        ),
      ),
    );
  }
}