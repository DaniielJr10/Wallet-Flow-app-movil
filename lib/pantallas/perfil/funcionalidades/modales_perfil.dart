/// MODALES Y DIÁLOGOS INTERACTIVOS
/// Contiene la lógica de UI para:
/// - El BottomSheet de selección de foto (Cámara, Galería, Eliminar).
/// - El diálogo de edición numérica (Límite de gasto).
/// - El diálogo de selección de categoría favorita.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils_perfil.dart';

class ModalesPerfil {
  /// Muestra opciones para cambiar la foto de perfil
  static void mostrarOpcionesFoto({
    required BuildContext context,
    required VoidCallback onCamara,
    required VoidCallback onGaleria,
    required VoidCallback onEliminar,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cambiar Foto de Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOpcionFoto(context, Icons.camera_alt, 'Cámara', onCamara),
                _buildOpcionFoto(context, Icons.photo_library, 'Galería', onGaleria),
                _buildOpcionFoto(context, Icons.delete, 'Eliminar', onEliminar, destructivo: true),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildOpcionFoto(
    BuildContext context,
    IconData icono,
    String titulo,
    VoidCallback onTap, {
    bool destructivo = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: destructivo 
                  ? Colors.red.withOpacity(0.1) 
                  : UtilsPerfil.colorPrincipal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: destructivo ? Colors.red : UtilsPerfil.colorPrincipal,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: destructivo ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para editar valor numérico
  static void mostrarDialogoNumerico({
    required BuildContext context,
    required String titulo,
    required double valorActual,
    required Function(double) onGuardar,
  }) {
    final controller = TextEditingController(text: valorActual.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor en COP',
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nuevoValor = double.tryParse(controller.text) ?? 0.0;
              onGuardar(nuevoValor);
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: UtilsPerfil.colorPrincipal)),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de selección de categoría
  static void mostrarSelectorCategoria({
    required BuildContext context,
    required String categoriaActual,
    required Function(String) onSeleccionado,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar Categoría Favorita'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: UtilsPerfil.categorias.length,
            itemBuilder: (context, index) {
              final categoria = UtilsPerfil.categorias[index];
              final esSeleccionada = categoria == categoriaActual;
              return ListTile(
                title: Text(categoria),
                trailing: esSeleccionada 
                    ? const Icon(Icons.check, color: UtilsPerfil.colorPrincipal) 
                    : null,
                onTap: () {
                  onSeleccionado(categoria);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}