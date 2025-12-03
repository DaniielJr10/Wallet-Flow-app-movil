import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactarSoporteScreen extends StatefulWidget {
  const ContactarSoporteScreen({super.key});

  @override
  State<ContactarSoporteScreen> createState() => _ContactarSoporteScreenState();
}

class _ContactarSoporteScreenState extends State<ContactarSoporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'mensaje': _mensajeController.text.trim(),
      'fecha': DateTime.now().toIso8601String(),
    };

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mensaje enviado'),
          content: const Text('Gracias por contactarnos. Te responderemos pronto.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Aceptar')),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu mensaje fue enviado')),
      );
    }

    // ignore: avoid_print
    print('Contacto soporte: $data');

    _mensajeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user != null && user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Usuario';
    final displayEmail = (user != null && user.email != null && user.email!.isNotEmpty)
        ? user.email!
        : 'correo@ejemplo.com';
    final initials = displayName.isNotEmpty ? displayName.trim()[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Contactar Soporte'),
        elevation: 0,
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile card (visual only)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF10B981),
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(displayEmail, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Only message field
                        Expanded(
                          child: TextFormField(
                            controller: _mensajeController,
                            decoration: InputDecoration(
                              labelText: 'Mensaje',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Cuéntanos tu problema o pregunta',
                              hintStyle: const TextStyle(fontSize: 14),
                            ),
                            style: const TextStyle(fontSize: 14),
                            maxLines: null,
                            expands: true,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Escribe un mensaje' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _enviar,
                                icon: const Icon(Icons.send_rounded),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Enviar mensaje', style: TextStyle(fontSize: 16)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
