import 'package:flutter/material.dart';

/// Formulario para crear o editar una meta de ahorro.
class FormularioAhorro extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController montoInicialController;
  final TextEditingController montoObjetivoController;
  final DateTime? fechaAhorro;
  final String categoriaAhorro;
  final List<Map<String, dynamic>> categorias;
  final bool esEdicion;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;
  final Function(DateTime) onFechaChanged;
  final Function(String) onCategoriaChanged;

  const FormularioAhorro({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.montoInicialController,
    required this.montoObjetivoController,
    required this.fechaAhorro,
    required this.categoriaAhorro,
    required this.categorias,
    required this.esEdicion,
    required this.onGuardar,
    required this.onCancelar,
    required this.onFechaChanged,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar formulario aquí
    return Container();
  }
}
