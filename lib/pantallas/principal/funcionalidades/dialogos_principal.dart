/// DIÁLOGOS DE LA PANTALLA PRINCIPAL
/// Centraliza los modales de confirmación, específicamente el de Cerrar Sesión.
import 'package:flutter/material.dart';

class DialogosPrincipal {
  static Future<bool?> confirmarCierreSesion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 24,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Cerrar Sesión', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión? Serás redirigido al menú principal.',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}