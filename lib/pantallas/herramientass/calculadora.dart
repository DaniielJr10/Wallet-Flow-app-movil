import 'package:flutter/material.dart';

/// =============================
/// Calculadora profesional y moderna
/// =============================
/// Esta pantalla implementa una calculadora elegante, con código mantenible y organizado.
/// La lógica de cálculo está separada en una clase aparte para facilitar pruebas y mantenimiento.

class CalculadoraPantalla extends StatefulWidget {
	const CalculadoraPantalla({super.key});

	@override
	State<CalculadoraPantalla> createState() => _CalculadoraPantallaState();
}

class _CalculadoraPantallaState extends State<CalculadoraPantalla> {
	final CalculadoraController _controller = CalculadoraController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF6F8FB),
			appBar: AppBar(
				title: const Text('Calculadora'),
				backgroundColor: const Color(0xFF10B981),
				elevation: 2,
				centerTitle: true,
			),
			body: SafeArea(
				child: Column(
					children: [
						const SizedBox(height: 24),
						// Pantalla de la calculadora
						_Display(
							expression: _controller.expression,
							result: _controller.result,
						),
						const SizedBox(height: 12),
						// Teclado de la calculadora
						Expanded(
							child: _CalculatorKeyboard(
								onKeyTap: (value) {
									setState(() {
										_controller.input(value);
									});
								},
								onDelete: () {
									setState(() {
										_controller.delete();
									});
								},
								onClear: () {
									setState(() {
										_controller.clear();
									});
								},
								onEquals: () {
									setState(() {
										_controller.calculate();
									});
								},
							),
						),
					],
				),
			),
		);
	}
}

/// Widget para mostrar la expresión y el resultado
class _Display extends StatelessWidget {
	final String expression;
	final String result;
	const _Display({required this.expression, required this.result});

	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 18),
			padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(24),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.withOpacity(0.08),
						blurRadius: 12,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.end,
				children: [
					Text(
						expression.isEmpty ? '0' : expression,
						style: const TextStyle(
							fontSize: 28,
							color: Color(0xFF22223B),
							fontWeight: FontWeight.w500,
						),
						maxLines: 2,
						overflow: TextOverflow.ellipsis,
					),
					const SizedBox(height: 8),
					AnimatedSwitcher(
						duration: const Duration(milliseconds: 250),
						child: Text(
							result,
							key: ValueKey(result),
							style: const TextStyle(
								fontSize: 36,
								color: Color(0xFF10B981),
								fontWeight: FontWeight.bold,
							),
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
						),
					),
				],
			),
		);
	}
}

/// Widget del teclado de la calculadora
class _CalculatorKeyboard extends StatelessWidget {
	final void Function(String) onKeyTap;
	final VoidCallback onDelete;
	final VoidCallback onClear;
	final VoidCallback onEquals;

	const _CalculatorKeyboard({
		required this.onKeyTap,
		required this.onDelete,
		required this.onClear,
		required this.onEquals,
	});

	@override
	Widget build(BuildContext context) {
		// Definición de las teclas
		final List<List<_CalcKey>> keys = [
			[
				_CalcKey(label: 'C', color: Colors.redAccent, onTap: onClear),
				_CalcKey(label: '⌫', color: Colors.orange, onTap: onDelete),
				_CalcKey(label: '%', color: Colors.blueGrey, onTap: () => onKeyTap('%')),
				_CalcKey(label: '÷', color: Colors.blue, onTap: () => onKeyTap('/')),
			],
			[
				_CalcKey(label: '7', onTap: () => onKeyTap('7')),
				_CalcKey(label: '8', onTap: () => onKeyTap('8')),
				_CalcKey(label: '9', onTap: () => onKeyTap('9')),
				_CalcKey(label: '×', color: Colors.blue, onTap: () => onKeyTap('*')),
			],
			[
				_CalcKey(label: '4', onTap: () => onKeyTap('4')),
				_CalcKey(label: '5', onTap: () => onKeyTap('5')),
				_CalcKey(label: '6', onTap: () => onKeyTap('6')),
				_CalcKey(label: '−', color: Colors.blue, onTap: () => onKeyTap('-')),
			],
			[
				_CalcKey(label: '1', onTap: () => onKeyTap('1')),
				_CalcKey(label: '2', onTap: () => onKeyTap('2')),
				_CalcKey(label: '3', onTap: () => onKeyTap('3')),
				_CalcKey(label: '+', color: Colors.blue, onTap: () => onKeyTap('+')),
			],
			[
				_CalcKey(label: '0', flex: 2, onTap: () => onKeyTap('0')),
				_CalcKey(label: '.', onTap: () => onKeyTap('.')),
				_CalcKey(label: '=', color: Color(0xFF10B981), onTap: onEquals),
			],
		];

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.end,
				children: keys.map((row) {
					return Expanded(
						child: Row(
							children: row.map((key) {
								return Expanded(
									flex: key.flex,
									child: Padding(
										padding: const EdgeInsets.all(6.0),
										child: ElevatedButton(
											onPressed: key.onTap,
											style: ElevatedButton.styleFrom(
												backgroundColor: key.color ?? Colors.white,
												foregroundColor: key.color != null ? Colors.white : const Color(0xFF22223B),
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(16),
												),
												elevation: key.color != null ? 2 : 0,
												textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
												padding: const EdgeInsets.symmetric(vertical: 18),
											),
											child: Text(key.label),
										),
									),
								);
							}).toList(),
						),
					);
				}).toList(),
			),
		);
	}
}

/// Modelo para cada tecla
class _CalcKey {
	final String label;
	final Color? color;
	final VoidCallback onTap;
	final int flex;
	_CalcKey({required this.label, this.color, required this.onTap, this.flex = 1});
}

/// Controlador de la lógica de la calculadora
class CalculadoraController {
	String expression = '';
	String result = '0';

	/// Procesa la entrada de teclas
	void input(String value) {
		if (value == '.' && expression.endsWith('.')) return;
		if (expression.length > 30) return; // Limita la longitud
		expression += value;
	}

	/// Borra el último carácter
	void delete() {
		if (expression.isNotEmpty) {
			expression = expression.substring(0, expression.length - 1);
		}
	}

	/// Limpia la calculadora
	void clear() {
		expression = '';
		result = '0';
	}

	/// Calcula el resultado de la expresión actual
	void calculate() {
		try {
			final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
			final parsed = _parseExpression(exp);
			result = parsed.toString();
		} catch (e) {
			result = 'Error';
		}
	}

	/// Evalúa la expresión matemática (solo operaciones básicas)
	double _parseExpression(String exp) {
		// Implementación simple usando la función de Dart
		// Para producción, usar un parser robusto o paquete externo
		// Aquí solo se permiten números, +, -, *, /, % y .
		exp = exp.replaceAll('%', '/100');
		// ignore: avoid_dynamic_calls, prefer_interpolation_to_compose_strings
		return double.parse(_evaluate(exp).toStringAsFixed(8));
	}

	/// Evaluador simple (solo para operaciones básicas)
	double _evaluate(String exp) {
		// Esta función es básica y no soporta paréntesis ni precedencia avanzada
		// Para una calculadora científica, usar un parser de expresiones
		try {
			// Multiplicación y división
			if (exp.contains('+')) {
				final parts = exp.split('+');
				return _evaluate(parts[0]) + _evaluate(parts.sublist(1).join('+'));
			}
			if (exp.contains('-')) {
				final parts = exp.split('-');
				return _evaluate(parts[0]) - _evaluate(parts.sublist(1).join('-'));
			}
			if (exp.contains('*')) {
				final parts = exp.split('*');
				return _evaluate(parts[0]) * _evaluate(parts.sublist(1).join('*'));
			}
			if (exp.contains('/')) {
				final parts = exp.split('/');
				return _evaluate(parts[0]) / _evaluate(parts.sublist(1).join('/'));
			}
			return double.parse(exp);
		} catch (_) {
			throw Exception('Expresión inválida');
		}
	}
}
