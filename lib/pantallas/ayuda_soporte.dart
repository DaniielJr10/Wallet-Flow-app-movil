import 'package:flutter/material.dart';

import 'preguntas_frecuentes.dart';
import 'contactar_soporte.dart';

class AyudaSoporteScreen extends StatelessWidget {
  const AyudaSoporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE6F9F0),
                    child: Icon(Icons.help_outline_rounded, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Preguntas Frecuentes'),
                  subtitle: const Text('Encuentra respuestas rápidas'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PreguntasFrecuentesScreen()),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF7E6),
                    child: Icon(Icons.support_agent, color: Color(0xFFF59E42)),
                  ),
                  title: const Text('Contactar Soporte'),
                  subtitle: const Text('Enviar mensaje al equipo de ayuda'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactarSoporteScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '¿Necesitas más ayuda?',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'También puedes visitar nuestra página de ayuda o escribirnos directamente desde la sección de Contactar Soporte. Responderemos lo antes posible.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
