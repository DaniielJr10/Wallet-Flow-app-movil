
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Una pantalla de conversor de monedas moderna y profesional.
class ConversorMonedasScreen extends StatefulWidget {
  const ConversorMonedasScreen({super.key});

  @override
  State<ConversorMonedasScreen> createState() => _ConversorMonedasScreenState();
}

class _ConversorMonedasScreenState extends State<ConversorMonedasScreen> {
  // Clave de API para la API de tipos de cambio.
  final String apiKey = "YOUR_API_KEY"; // Reemplaza con tu clave de API
  // URL base para la API de tipos de cambio.
  final String apiUrl = "https://v6.exchangerate-api.com/v6/";

  // Monedas disponibles para la conversión.
  List<String> currencies = [];
  // Moneda seleccionada para "desde".
  String fromCurrency = "USD";
  // Moneda seleccionada para "a".
  String toCurrency = "EUR";
  // Cantidad a convertir.
  double amount = 1.0;
  // Resultado de la conversión.
  String result = "";

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  // Obtiene la lista de monedas disponibles desde la API.
  Future<void> _getCurrencies() async {
    // Para este ejemplo, usaremos una lista predefinida.
    // En una aplicación real, obtendrías esto desde la API.
    setState(() {
      currencies = ["USD", "EUR", "COP", "GBP", "JPY", "CAD", "AUD"];
      // Asegúrate de que las monedas predeterminadas estén en la lista.
      if (!currencies.contains(fromCurrency)) {
        fromCurrency = currencies.isNotEmpty ? currencies.first : 'USD';
      }
      if (!currencies.contains(toCurrency)) {
        toCurrency = currencies.length > 1 ? currencies[1] : 'EUR';
      }
    });
  }

  // Realiza la conversión de moneda.
  Future<void> _convert() async {
    if (apiKey == "YOUR_API_KEY") {
      setState(() {
        result = "Por favor, añade tu clave de API.";
      });
      return;
    }
    var response = await http.get(Uri.parse("$apiUrl$apiKey/latest/$fromCurrency"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double rate = data['conversion_rates'][toCurrency];
      setState(() {
        result = (amount * rate).toStringAsFixed(2);
      });
    } else {
      setState(() {
        result = "Error al obtener los datos.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Monedas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de entrada para la cantidad.
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                amount = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 20),
            // Dropdowns para seleccionar las monedas.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCurrencyDropdown("Desde", fromCurrency, (newValue) {
                  setState(() {
                    fromCurrency = newValue!;
                  });
                }),
                const Icon(Icons.swap_horiz, size: 40, color: Colors.deepPurple),
                _buildCurrencyDropdown("A", toCurrency, (newValue) {
                  setState(() {
                    toCurrency = newValue!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 30),
            // Botón para realizar la conversión.
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Convertir'),
            ),
            const SizedBox(height: 30),
            // Muestra el resultado de la conversión.
            Text(
              result,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir los dropdowns de selección de moneda.
  Widget _buildCurrencyDropdown(String title, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        DropdownButton<String>(
          value: value,
          items: currencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
