import 'package:flutter/material.dart';

/// Formulario para crear o editar un gasto.
class FormularioGasto extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController montoController;
  final TextEditingController descripcionController;
  final DateTime? fechaSeleccionada;
  final String categoriaSeleccionada;
  final String metodoPagoSeleccionado;
  final String cuentaAsociada;
  final bool esRecurrente;
  final String frecuenciaRecurrente;
  final List<String> categorias;
  final List<String> metodosPago;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;
  final Function(DateTime) onFechaChanged;
  final Function(String) onCategoriaChanged;
  final Function(String) onMetodoPagoChanged;
  final Function(String) onCuentaAsociadaChanged;

  const FormularioGasto({
    super.key,
    required this.formKey,
    required this.montoController,
    required this.descripcionController,
    required this.fechaSeleccionada,
    required this.categoriaSeleccionada,
    required this.metodoPagoSeleccionado,
    required this.cuentaAsociada,
    required this.esRecurrente,
    required this.frecuenciaRecurrente,
    required this.categorias,
    required this.metodosPago,
    required this.onGuardar,
    required this.onCancelar,
    required this.onFechaChanged,
    required this.onCategoriaChanged,
    required this.onMetodoPagoChanged,
    required this.onCuentaAsociadaChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar formulario aquí
    return Container();
  }
}
