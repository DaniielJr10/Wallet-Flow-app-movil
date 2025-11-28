/// LÓGICA MATEMÁTICA (CONTROLLER)
/// Maneja el estado de la calculadora: la expresión actual, el cálculo
/// del resultado, el formateo de números y las operaciones (input, delete, clear).
/// Utiliza `dart:math` para raíz cuadrada.
import 'dart:math' as math;
// Ajusta la ruta de importación según tu estructura de carpetas
import '../../../../../../utilidades/formato_numeros.dart';

// Esta es la API de la calculadora

class CalculadoraController {
  String expression = '';
  String result = '0';
  bool _justCalculated = false;

  void input(String value) {
    if (value == '.' && expression.endsWith('.')) return;
    if (expression.length > 60) return;

    // Si la última acción fue calcular:
    // - Escribir un número inicia una nueva expresión.
    // - Escribir un operador continúa con el resultado anterior.
    if (_justCalculated) {
      if (RegExp(r'[0-9.]').hasMatch(value)) {
        expression = '';
        result = '0';
        _justCalculated = false;
      } else {
        expression = result.replaceAll(RegExp(r'[^0-9\.-]'), '');
        _justCalculated = false;
      }
    }
    
    // Evitar doble operador
    if (expression.isNotEmpty && _isOperator(expression.substring(expression.length - 1)) && _isOperator(value)) {
      expression = expression.substring(0, expression.length - 1) + value;
      return;
    }
    expression += value;
  }

  void delete() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
    }
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
        expression = expression.substring(0, numMatch.start) + val.toString();
      } catch (_) {}
    }
  }

  void sqrtCurrent() {
    try {
      final raw = expression.isEmpty ? result.replaceAll(RegExp(r'[^0-9\.-]'), '') : expression;
      final value = double.parse(raw);
      final r = math.sqrt(value);
      result = _format(r);
      expression = r.toString();
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
      expression = parsed.toString();
      _justCalculated = true;
    } catch (_) {
      result = 'Error';
    }
  }

  // Helpers internos
  bool _isOperator(String s) => ['+', '-', '*', '/', '%'].contains(s);

  String _format(double v) {
    if (v == v.roundToDouble() && v.abs() >= 1000) {
      return FormatoNumeros.formatearNumero(v.toInt());
    }
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
    
    // Post-procesamiento de porcentaje
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

// Fin de la API de la calculadora