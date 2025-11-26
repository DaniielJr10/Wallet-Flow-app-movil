/// INPUT DE EMAIL
/// Campo especializado para correos, utilizando el validador robusto
/// definido en utils_registro.dart.
import 'package:flutter/material.dart';
import 'utils_registro.dart';

class CampoEmail extends StatelessWidget {
  final TextEditingController controller;

  const CampoEmail({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UtilsRegistro.colorPrincipal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: UtilsRegistro.validateEmail,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          hintText: 'ejemplo@correo.com',
          prefixIcon: const Icon(Icons.email_outlined, color: UtilsRegistro.colorSecundario),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: UtilsRegistro.colorTexto, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.7)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorPrincipal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: UtilsRegistro.colorError, width: 2),
          ),
        ),
      ),
    );
  }
}