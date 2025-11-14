import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Clase utilitaria para formatear números con separador de miles usando puntos
class FormatoNumeros {
  
  /// Formatea un número con separador de miles usando puntos
  /// Ejemplo: 45789 -> "45.789"
  static String formatearNumero(dynamic numero) {
    if (numero == null) return '0';
    
    double valor;
    if (numero is String) {
      valor = double.tryParse(numero.replaceAll('.', '')) ?? 0;
    } else {
      valor = numero.toDouble();
    }
    
    // Si es un número entero, no mostrar decimales
    if (valor == valor.toInt()) {
      return NumberFormat('#,###', 'es_ES').format(valor.toInt()).replaceAll(',', '.');
    } else {
      // Si tiene decimales, mostrar máximo 2
      return NumberFormat('#,###.##', 'es_ES').format(valor).replaceAll(',', '.');
    }
  }

  /// Formatea un número para mostrar en pantalla sin decimales si es entero
  static String formatearParaMostrar(dynamic numero) {
    if (numero == null) return '0';
    
    double valor;
    if (numero is String) {
      valor = double.tryParse(numero.replaceAll('.', '')) ?? 0;
    } else {
      valor = numero.toDouble();
    }
    
    if (valor == valor.toInt()) {
      return NumberFormat('#,###', 'es_ES').format(valor.toInt()).replaceAll(',', '.');
    } else {
      return NumberFormat('#,###.00', 'es_ES').format(valor).replaceAll(',', '.');
    }
  }

  /// Convierte un texto formateado de vuelta a número
  /// Ejemplo: "45.789" -> 45789
  static double? convertirANumero(String texto) {
    if (texto.isEmpty) return null;
    // Remover todos los puntos excepto el último si hay decimales
    String textoLimpio = texto.replaceAll('.', '');
    return double.tryParse(textoLimpio);
  }

  /// Verifica si un texto tiene el formato correcto
  static bool esFormatoValido(String texto) {
    if (texto.isEmpty) return true;
    // Patrón para números con separador de miles con puntos
    RegExp patron = RegExp(r'^\d{1,3}(\.\d{3})*(\,\d{1,2})?$');
    return patron.hasMatch(texto);
  }
}

/// InputFormatter personalizado para formatear números mientras se escriben
class FormateadorNumeros extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remover todos los caracteres que no sean dígitos
    String digitos = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitos.isEmpty) {
      return const TextEditingValue();
    }

    // Formatear con separador de miles
    String textoFormateado = _formatearConSeparador(digitos);
    
    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: textoFormateado.length),
    );
  }

  String _formatearConSeparador(String digitos) {
    if (digitos.length <= 3) {
      return digitos;
    }

    // Insertar puntos cada 3 dígitos desde la derecha
    String resultado = '';
    for (int i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) {
        resultado += '.';
      }
      resultado += digitos[i];
    }
    
    return resultado;
  }
}

/// InputFormatter para números con decimales
class FormateadorNumerosConDecimales extends TextInputFormatter {
  final int decimales;
  
  FormateadorNumerosConDecimales({this.decimales = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Permitir solo dígitos y una coma para decimales
    String texto = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');
    
    // Solo permitir una coma
    List<String> partes = texto.split(',');
    if (partes.length > 2) {
      texto = '${partes[0]},${partes[1]}';
    }
    
    // Limitar decimales
    if (partes.length == 2 && partes[1].length > decimales) {
      texto = '${partes[0]},${partes[1].substring(0, decimales)}';
    }

    // Formatear la parte entera con separador de miles
    if (partes[0].isNotEmpty) {
      String parteEntera = _formatearConSeparador(partes[0]);
      if (partes.length > 1) {
        texto = '$parteEntera,${partes[1]}';
      } else {
        texto = parteEntera;
      }
    }
    
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  String _formatearConSeparador(String digitos) {
    if (digitos.length <= 3) {
      return digitos;
    }

    String resultado = '';
    for (int i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) {
        resultado += '.';
      }
      resultado += digitos[i];
    }
    
    return resultado;
  }
}
