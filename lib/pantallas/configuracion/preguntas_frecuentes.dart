import 'package:flutter/material.dart';

class PreguntasFrecuentesScreen extends StatefulWidget {
  const PreguntasFrecuentesScreen({super.key});

  @override
  State<PreguntasFrecuentesScreen> createState() => _PreguntasFrecuentesScreenState();
}

class _PreguntasFrecuentesScreenState extends State<PreguntasFrecuentesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _faqs = [
    // Removed two questions per user request
    {
      'q': '¿Puedo pagar deudas desde la app?',
      'a': 'Sí: al ver una deuda, pulsa "Pagar", selecciona la cuenta desde la que pagar y confirma. El saldo de la cuenta se actualizará automáticamente.'
    },
    {
      'q': '¿Cómo recupero mi contraseña?',
      'a': 'En la pantalla de inicio de sesión usa "Recuperar contraseña" para recibir un enlace por correo.'
    },
    {
      'q': '¿Puedo exportar o hacer copia de mis datos?',
      'a': 'Sí: en Herramientas > Exportar Datos puedes generar y descargar tus transacciones en formatos comunes (CSV/PDF).'
    },
    {
      'q': '¿Cómo contacto soporte directamente?',
      'a': 'En Configuración > Contactar Soporte escribe tu mensaje; se enviará al equipo desde la app.'
    },
    {
      'q': '¿Cómo elimino mi cuenta y datos?',
      'a': 'En Configuración > Datos y Privacidad encontrarás la opción para eliminar tu cuenta. Esto borra tus datos de nuestra base y no se puede deshacer.'
    },
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_faqs);
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final term = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (term.isEmpty) {
        _filtered = List.from(_faqs);
      } else {
        _filtered = _faqs.where((f) {
          return f['q']!.toLowerCase().contains(term) || f['a']!.toLowerCase().contains(term);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'),
        elevation: 0,
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar pregunta o palabra clave',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Encuentra soluciones rápidas a las dudas más comunes',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.question_mark, color: Color(0xFF10B981)),
                    ),
                    title: Text(
                      item['q']!,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item['a']!, style: TextStyle(color: Colors.grey.shade800)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
