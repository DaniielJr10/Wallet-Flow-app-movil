import 'package:flutter/material.dart';
import 'soporte_modelos.dart';

/// Widgets de formulario para la pantalla de contactar soporte
class SoporteWidgetsFormulario {
  /// Construye el selector de categoría
  static Widget buildSelectorCategoria({
    required String categoriaSeleccionada,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Categoría del problema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              tooltip: 'Información sobre categorías',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: SoporteConstantes.getCategoriaByNombre(categoriaSeleccionada)
                .color
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SoporteConstantes.getCategoriaByNombre(categoriaSeleccionada)
                  .color
                  .withOpacity(0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: categoriaSeleccionada,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              SoporteConstantes.getCategoriaByNombre(categoriaSeleccionada).icono,
              color: SoporteConstantes.getCategoriaByNombre(categoriaSeleccionada).color,
            ),
            onChanged: (String? nuevaCategoria) {
              if (nuevaCategoria != null) {
                onChanged(nuevaCategoria);
              }
            },
            items: SoporteConstantes.categorias.map<DropdownMenuItem<String>>((categoria) {
              return DropdownMenuItem<String>(
                value: categoria.nombre,
                child: Row(
                  children: [
                    Icon(
                      categoria.icono,
                      color: categoria.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria.nombre,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            categoria.descripcion,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  /// Construye el campo de asunto
  static Widget buildCampoAsunto({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asunto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Resumen breve de tu consulta',
            hintStyle: TextStyle(color: Colors.grey.shade500),
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              Icons.subject,
              color: Colors.grey.shade600,
            ),
          ),
          validator: ValidacionFormulario.validarAsunto,
        ),
      ],
    );
  }

  /// Construye el campo de mensaje
  static Widget buildCampoMensaje({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mensaje detallado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Describe detalladamente tu problema o pregunta...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
          validator: ValidacionFormulario.validarMensaje,
        ),
      ],
    );
  }
}