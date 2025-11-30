/// SECCIÓN DE INFORMACIÓN PERSONAL
/// Agrupa los campos de texto (Nombre, Email, Biografía) y la información
/// de metadatos (Fechas de registro) en un contenedor unificado.
/// Utiliza los widgets de `inputs_perfil.dart`.
import 'package:flutter/material.dart';
import 'inputs_perfil.dart';
import 'utils_perfil.dart';

class FormularioInformacion extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController emailController;
  final TextEditingController biografiaController;
  final bool modoEdicion;
  final Map<String, dynamic> datosUsuario;
  final VoidCallback onRequestEdit;

  const FormularioInformacion({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.emailController,
    required this.biografiaController,
    required this.modoEdicion,
    required this.datosUsuario,
    required this.onRequestEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: UtilsPerfil.colorTexto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo nombre (tocar para activar edición)
            GestureDetector(
              onTap: modoEdicion ? null : onRequestEdit,
              child: AbsorbPointer(
                absorbing: !modoEdicion,
                child: CampoTextoPerfil(
                  controller: nombreController,
                  label: 'Nombre Completo',
                  icono: Icons.person,
                  habilitado: modoEdicion,
                  validador: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Campo email (tocar para activar edición)
            GestureDetector(
              onTap: modoEdicion ? null : onRequestEdit,
              child: AbsorbPointer(
                absorbing: !modoEdicion,
                child: CampoTextoPerfil(
                  controller: emailController,
                  label: 'Correo Electrónico',
                  icono: Icons.email,
                  habilitado: modoEdicion,
                  tipoTeclado: TextInputType.emailAddress,
                    validador: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El email es requerido';
                      }
                      return null;
                    },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ... Campo biografía eliminado ...

            // Información de solo lectura (fechas)
            if (!modoEdicion) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildInfoItem(
                'Fecha de registro',
                UtilsPerfil.formatearFecha(datosUsuario['fechaRegistro']),
                Icons.calendar_today,
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoItem(
                'Último acceso',
                UtilsPerfil.formatearFecha(datosUsuario['ultimoAcceso']),
                Icons.access_time,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          color: const Color(0xFF6B7280),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          valor,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}