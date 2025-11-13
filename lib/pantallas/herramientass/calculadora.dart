import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Calculadora profesional y moderna (móvil)
/// Diseño limpio, sin historial (por petición del usuario).

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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2FBF5), Color(0xFFF9FDFB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.calculate, color: Color(0xFF10B981), size: 30),
                          SizedBox(width: 10),
                          Text(
                            'CALCULADORA',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Herramienta de cálculo financiero avanzada',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              const SizedBox(height: 18),

              // Card central
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      _Display(
                        expression: _controller.expression,
                        result: _controller.result,
                      ),
                      const SizedBox(height: 12),
                      _KeyboardArea(
                        controller: _controller,
                        onStateChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _BottomActions(
                        controller: _controller,
                        onStateChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Display: expresión (scroll horizontal) + resultado (FittedBox para evitar montado)
class _Display extends StatelessWidget {
  final String expression;
  final String result;
  const _Display({required this.expression, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFF6E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 28,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: const TextStyle(fontSize: 18, color: Color(0xFF22223B), fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        result,
                        key: ValueKey(result),
                        style: const TextStyle(fontSize: 48, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Teclado: teclas blancas y columna/operadores verdes
class _KeyboardArea extends StatelessWidget {
  final CalculadoraController controller;
  final VoidCallback onStateChanged;

  const _KeyboardArea({required this.controller, required this.onStateChanged});

  Widget _whiteKey(String label, {VoidCallback? onTap, int flex = 1, Color? borderColor, Color? textColor}) {
    final bool outlined = borderColor != null && (label == 'AC' || label == 'CE' || label == '⌫');
    final Color effectiveBorder = borderColor ?? const Color(0xFFE6F5EB);
    final Color effectiveText = textColor ?? const Color(0xFF1F2937);
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 70,
          child: outlined
              ? OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: effectiveBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(label, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: effectiveText)),
                )
              : ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: effectiveText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: effectiveBorder),
                    minimumSize: const Size.fromHeight(70),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  child: Text(label, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                ),
        ),
      ),
    );
  }

  Widget _greenKey(String label, {VoidCallback? onTap, Color? color, int flex = 1}) {
    final Color start = const Color(0xFF34D399);
    final Color end = color ?? const Color(0xFF10B981);
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [start, end]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: end.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Center(child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              _whiteKey('AC', onTap: () {
                controller.clearAll();
                onStateChanged();
              }, borderColor: const Color(0xFFFEE2E2), textColor: const Color(0xFFEF4444)),
              _whiteKey('CE', onTap: () {
                controller.clearEntry();
                onStateChanged();
              }, borderColor: const Color(0xFFFFF7ED), textColor: const Color(0xFFFFA726)),
              _whiteKey('⌫', onTap: () {
                controller.delete();
                onStateChanged();
              }, borderColor: const Color(0xFFFFF7ED), textColor: const Color(0xFFF59E0B)),
              _greenKey('÷', onTap: () {
                controller.input('/');
                onStateChanged();
              }),
            ],
          ),
          Row(
            children: [
              _whiteKey('7', onTap: () {
                controller.input('7');
                onStateChanged();
              }),
              _whiteKey('8', onTap: () {
                controller.input('8');
                onStateChanged();
              }),
              _whiteKey('9', onTap: () {
                controller.input('9');
                onStateChanged();
              }),
              _greenKey('×', onTap: () {
                controller.input('*');
                onStateChanged();
              }),
            ],
          ),
          Row(
            children: [
              _whiteKey('4', onTap: () {
                controller.input('4');
                onStateChanged();
              }),
              _whiteKey('5', onTap: () {
                controller.input('5');
                onStateChanged();
              }),
              _whiteKey('6', onTap: () {
                controller.input('6');
                onStateChanged();
              }),
              _greenKey('−', onTap: () {
                controller.input('-');
                onStateChanged();
              }),
            ],
          ),
          Row(
            children: [
              _whiteKey('1', onTap: () {
                controller.input('1');
                onStateChanged();
              }),
              _whiteKey('2', onTap: () {
                controller.input('2');
                onStateChanged();
              }),
              _whiteKey('3', onTap: () {
                controller.input('3');
                onStateChanged();
              }),
              _greenKey('+', onTap: () {
                controller.input('+');
                onStateChanged();
              }),
            ],
          ),
          Row(
            children: [
              _whiteKey('0', flex: 2, onTap: () {
                controller.input('0');
                onStateChanged();
              }),
              _whiteKey('.', onTap: () {
                controller.input('.');
                onStateChanged();
              }),
              _greenKey('=', color: const Color(0xFF0B8F59), onTap: () {
                controller.calculate();
                onStateChanged();
              }),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botones inferiores: % y √
class _BottomActions extends StatelessWidget {
  final CalculadoraController controller;
  final VoidCallback onStateChanged;

  const _BottomActions({required this.controller, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.percent();
                    onStateChanged();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(child: Text('%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.sqrtCurrent();
                    onStateChanged();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(child: Text('√', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lógica de la calculadora (simple, sin paréntesis avanzados)
class CalculadoraController {
  String expression = '';
  String result = '0';
  bool _justCalculated = false;

  void input(String value) {
    if (value == '.' && expression.endsWith('.')) return;
    if (expression.length > 60) return;
    if (_justCalculated && RegExp(r'[0-9.]').hasMatch(value)) {
      expression = '';
      result = '0';
      _justCalculated = false;
    }
    if (expression.isNotEmpty && _isOperator(expression.substring(expression.length - 1)) && _isOperator(value)) {
      expression = expression.substring(0, expression.length - 1) + value;
      return;
    }
    expression += value;
  }

  void delete() {
    if (expression.isNotEmpty) expression = expression.substring(0, expression.length - 1);
  }

  void clearAll() {
    expression = '';
    result = '0';
  }

  void clearEntry() {
    expression = '';
  }

  void percent() {
    if (expression.isEmpty) return;
    final numMatch = RegExp(r'([0-9.]+)$').firstMatch(expression);
    if (numMatch != null) {
      final numStr = numMatch.group(1)!;
      try {
        final val = double.parse(numStr) / 100.0;
        expression = expression.substring(0, numMatch.start) + _format(val);
      } catch (_) {}
    }
  }

  void sqrtCurrent() {
    try {
      final value = double.parse(expression.isEmpty ? result : expression);
      final r = math.sqrt(value);
      result = _format(r);
      expression = result;
      _justCalculated = true;
    } catch (_) {
      result = 'Error';
    }
  }

  void calculate() {
    try {
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final parsed = _parseExpression(exp);
      result = _format(parsed);
      _justCalculated = true;
    } catch (_) {
      result = 'Error';
    }
  }

  // Helpers
  bool _isOperator(String s) => ['+', '-', '*', '/', '%'].contains(s);

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  double _parseExpression(String exp) {
    exp = exp.replaceAll('%', '/100');
    final tokens = _tokenize(exp);
    if (tokens.isEmpty) throw Exception('Empty');
    final t1 = <String>[];
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token == '*' || token == '/') {
        final left = double.parse(t1.removeLast());
        final right = double.parse(tokens[++i]);
        final res = token == '*' ? left * right : left / right;
        t1.add(res.toString());
      } else {
        t1.add(token);
      }
    }
    double acc = double.parse(t1[0]);
    for (int i = 1; i < t1.length; i += 2) {
      final op = t1[i];
      final val = double.parse(t1[i + 1]);
      if (op == '+') acc += val;
      else if (op == '-') acc -= val;
      else throw Exception('Operador inválido');
    }
    return acc;
  }

  List<String> _tokenize(String exp) {
    final List<String> tokens = [];
    final buffer = StringBuffer();
    for (int i = 0; i < exp.length; i++) {
      final ch = exp[i];
      if ("0123456789.".contains(ch)) {
        buffer.write(ch);
      } else if ("+-*/".contains(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        if (ch == '-' && (tokens.isEmpty || (tokens.isNotEmpty && _isOperator(tokens.last)))) {
          buffer.write('-');
        } else {
          tokens.add(ch);
        }
      } else if (ch == '%') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add('%');
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    final List<String> out = [];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '%') {
        out.add('/');
        out.add('100');
      } else {
        out.add(tokens[i]);
      }
    }
    return out;
  }
}

 
