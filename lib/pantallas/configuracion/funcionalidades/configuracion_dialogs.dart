/**
 * FUNCIONALIDAD: Diálogos y modales de configuración
 * 
 * Este archivo contiene todos los diálogos, modales y ventanas emergentes
 * utilizados en la pantalla de configuración:
 * - Diálogo "Acerca de" con información de la aplicación
 * - Componentes reutilizables para información de la app
 * - Diálogos personalizados con animaciones
 * - Widgets informativos con estilo consistente
 */

import 'package:flutter/material.dart';

class ConfiguracionDialogs {

  /// Muestra el diálogo "Acerca de" con información de la aplicación
  static void mostrarAcercaDe(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Acerca de',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo de la aplicación
                  _buildLogoApp(),
                  const SizedBox(height: 12),
                  
                  // Nombre de la aplicación
                  const Text(
                    'Wallet Flow', 
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Versión
                  Text(
                    'Versión 1.0.0', 
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Información adicional
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  
                  // Botón de cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
      },
    );
  }

  /// Construye el logo de la aplicación
  static Widget _buildLogoApp() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'images/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Si no se puede cargar la imagen, mostrar un icono
            return const Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: Color(0xFF10B981),
            );
          },
        ),
      ),
    );
  }

  /// Construye la sección de información de la aplicación
  static Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SmallInfoItem(
            title: 'Desarrollador',
            subtitle: 'Wallet Flow Team',
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          SmallInfoItem(
            title: 'Última Actualización',
            subtitle: DateTime.now().year.toString(),
            icon: Icons.update,
          ),
          const SizedBox(height: 12),
          SmallInfoItem(
            title: 'Correo',
            subtitle: 'walletfloww@gmail.com',
            icon: Icons.email,
          ),
        ],
      ),
    );
  }

  /// Diálogo simple con mensaje personalizado
  static Future<void> mostrarDialogoSimple({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String? textoBoton,
    VoidCallback? onConfirmar,
    Color? colorBoton,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Text(
            mensaje,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            if (onConfirmar != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorBoton ?? const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(textoBoton ?? 'Confirmar'),
              ),
          ],
        );
      },
    );
  }

  /// Diálogo de confirmación reutilizable
  static Future<bool> mostrarDialogoConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    Color colorConfirmar = const Color(0xFF10B981),
    bool esDestructivo = false,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esDestructivo ? Colors.red : const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          mensaje,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(textoCancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: esDestructivo ? Colors.red : colorConfirmar,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  /// Diálogo de carga con spinner
  static void mostrarDialogoCarga({
    required BuildContext context,
    String mensaje = 'Procesando...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
              const SizedBox(height: 16),
              Text(
                mensaje,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cierra el diálogo de carga
  static void cerrarDialogoCarga(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Widget para mostrar información pequeña con icono
class SmallInfoItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const SmallInfoItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

