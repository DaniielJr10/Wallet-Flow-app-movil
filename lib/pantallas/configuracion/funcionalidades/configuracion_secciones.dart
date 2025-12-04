/**
 * FUNCIONALIDAD: Widgets de secciones de configuración
 * 
 * Este archivo contiene todos los widgets reutilizables para construir
 * las diferentes secciones de la pantalla de configuración:
 * - Sección de Notificaciones
 * - Sección de Datos y Privacidad 
 * - Sección de Ayuda y Soporte
 * - Widgets base para secciones, switch tiles y option tiles
 */

import 'package:flutter/material.dart';

class ConfiguracionSecciones {
  
  /// Construye la sección de notificaciones
  static Widget buildSeccionNotificaciones({
    required bool notificacionesActivas,
    required ValueChanged<bool> onNotificacionesChanged,
    required Future<void> Function(String, dynamic) guardarConfiguracion,
  }) {
    return _buildSeccion(
      titulo: 'Notificaciones',
      icono: Icons.notifications,
      color: const Color(0xFFF59E0B),
      children: [
        _buildSwitchTile(
          titulo: 'Notificaciones Push',
          subtitulo: 'Recibir alertas importantes',
          icono: Icons.notifications_active,
          valor: notificacionesActivas,
          onChanged: (value) async {
            onNotificacionesChanged(value);
            await guardarConfiguracion('notificaciones_activas', value);
          },
        ),
      ],
    );
  }

  /// Construye la sección de datos y privacidad
  static Widget buildSeccionDatos({
    required VoidCallback onCambiarContrasena,
    required VoidCallback onExportarDatos,
    required VoidCallback onEliminarCuenta,
  }) {
    return _buildSeccion(
      titulo: 'Datos y Privacidad',
      icono: Icons.data_usage,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildOpcionTile(
          titulo: 'Cambiar Contraseña',
          subtitulo: 'Actualizar contraseña de tu cuenta',
          icono: Icons.lock,
          onTap: onCambiarContrasena,
        ),
        const SizedBox(height: 8),
        _buildOpcionTile(
          titulo: 'Exportar Datos',
          subtitulo: 'Descargar información en Excel/PDF',
          icono: Icons.download,
          onTap: onExportarDatos,
        ),
        _buildOpcionTile(
          titulo: 'Eliminar Cuenta',
          subtitulo: 'Eliminar permanentemente tu cuenta',
          icono: Icons.delete_forever,
          onTap: onEliminarCuenta,
          esDestructivo: true,
        ),
      ],
    );
  }

  /// Construye la sección de ayuda y soporte
  static Widget buildSeccionAyuda({
    required VoidCallback onAbrirFAQ,
    required VoidCallback onContactarSoporte,
    required VoidCallback onMostrarAcercaDe,
  }) {
    return _buildSeccion(
      titulo: 'Ayuda y Soporte',
      icono: Icons.help,
      color: const Color(0xFF06B6D4),
      children: [
        _buildOpcionTile(
          titulo: 'Preguntas Frecuentes',
          subtitulo: 'Encuentra respuestas rápidas',
          icono: Icons.quiz,
          onTap: onAbrirFAQ,
        ),
        _buildOpcionTile(
          titulo: 'Contactar Soporte',
          subtitulo: 'Enviar mensaje al equipo de ayuda',
          icono: Icons.support_agent,
          onTap: onContactarSoporte,
        ),
        _buildOpcionTile(
          titulo: 'Acerca de',
          subtitulo: 'Versión 1.0.0 - Wallet Flow',
          icono: Icons.info,
          onTap: onMostrarAcercaDe,
        ),
      ],
    );
  }

  /// Widget base para construir una sección con título e icono
  static Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Widget para opciones con switch (activar/desactivar)
  static Widget _buildSwitchTile({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, color: const Color(0xFF10B981), size: 20),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: Switch(
        value: valor,
        onChanged: onChanged,
        activeColor: const Color(0xFF10B981),
      ),
    );
  }

  /// Widget para opciones clickeables (navegación o acciones)
  static Widget _buildOpcionTile({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required VoidCallback onTap,
    bool esDestructivo = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: esDestructivo
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icono,
          color: esDestructivo ? Colors.red : const Color(0xFF10B981),
          size: 20,
        ),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: esDestructivo ? Colors.red : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}