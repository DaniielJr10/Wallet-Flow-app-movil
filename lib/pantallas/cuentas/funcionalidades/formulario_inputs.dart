/// WIDGETS DE FORMULARIO
/// Componentes reutilizables para los inputs de texto y el selector
/// de tipo de cuenta, encargados de la estética y validación visual.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectorTipoCuenta extends StatelessWidget {
  final List<Map<String, dynamic>> tiposCuenta;
  final String tipoSeleccionado;
  final Function(String) onSeleccionado;

  const SelectorTipoCuenta({
    super.key,
    required this.tiposCuenta,
    required this.tipoSeleccionado,
    required this.onSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tiposCuenta.length,
      itemBuilder: (context, index) {
        final tipo = tiposCuenta[index];
        final seleccionado = tipoSeleccionado == tipo['valor'];
        
        return InkWell(
          onTap: () => onSeleccionado(tipo['valor']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: seleccionado 
                ? tipo['color'].withOpacity(0.1)
                : Colors.grey[50],
              border: Border.all(
                color: seleccionado 
                  ? tipo['color']
                  : Colors.grey[300]!,
                width: seleccionado ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  tipo['icono'],
                  color: seleccionado 
                    ? tipo['color']
                    : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tipo['nombre'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: seleccionado 
                        ? FontWeight.w600
                        : FontWeight.normal,
                      color: seleccionado 
                        ? tipo['color']
                        : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InputFormularioCuenta extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const InputFormularioCuenta({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF007bff)),
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}