import 'package:flutter/material.dart';

/// Formulario para crear o editar una deuda.
class FormularioDeuda extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tituloController;
  final TextEditingController montoController;
  final TextEditingController pagoMinimoController;
  final TextEditingController acreedorController;
  final String tipoSeleccionado;
  final DateTime fechaVencimiento;
  final bool esEdicion;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;
  final Function(DateTime) onFechaChanged;
  final Function(String) onTipoChanged;

  const FormularioDeuda({
    super.key,
    required this.formKey,
    required this.tituloController,
    required this.montoController,
    required this.pagoMinimoController,
    required this.acreedorController,
    required this.tipoSeleccionado,
    required this.fechaVencimiento,
    required this.esEdicion,
    required this.onGuardar,
    required this.onCancelar,
    required this.onFechaChanged,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Implementar formulario aquí
    return Container();
  }
}
