import 'package:flutter/material.dart';
import 'utilidades/formato_numeros.dart';

/// Ejemplo de uso del formateador de números
void main() {
  // Ejemplos de formateo
  print('Ejemplos de formato:');
  print('45789 -> ${FormatoNumeros.formatearNumero(45789)}');
  print('78990 -> ${FormatoNumeros.formatearNumero(78990)}');
  print('567988130 -> ${FormatoNumeros.formatearNumero(567988130)}');
  print('6700 -> ${FormatoNumeros.formatearNumero(6700)}');
  print('1000000 -> ${FormatoNumeros.formatearNumero(1000000)}');
  
  print('\nConversión de vuelta a número:');
  print('45.789 -> ${FormatoNumeros.convertirANumero('45.789')}');
  print('567.988.130 -> ${FormatoNumeros.convertirANumero('567.988.130')}');
}

class EjemploFormato extends StatefulWidget {
  const EjemploFormato({super.key});

  @override
  State<EjemploFormato> createState() => _EjemploFormatoState();
}

class _EjemploFormatoState extends State<EjemploFormato> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo de Formato')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FormateadorNumeros()],
              decoration: const InputDecoration(
                labelText: 'Ingresa un número',
                hintText: '45.789',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Valor formateado: ${_controller.text}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Valor numérico: ${FormatoNumeros.convertirANumero(_controller.text)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
