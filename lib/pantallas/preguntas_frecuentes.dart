import 'package:flutter/material.dart';

class PreguntasFrecuentesScreen extends StatefulWidget {
  const PreguntasFrecuentesScreen({super.key});

  @override
  State<PreguntasFrecuentesScreen> createState() => _PreguntasFrecuentesScreenState();
}

class _PreguntasFrecuentesScreenState extends State<PreguntasFrecuentesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'q': '¿Cómo añado una cuenta bancaria?',
      'a': 'Ve a Cuentas > Añadir cuenta y completa los datos solicitados.'
    },
    {
      'q': '¿Cómo exporto mis transacciones?',
      'a': 'En Herramientas selecciona Exportar Datos y elige el formato.'
    },
    {
      'q': 'Olvidé mi contraseña, ¿qué hago?',
      'a': 'Usa la función de recuperación desde la pantalla de inicio de sesión.'
    },
    {
      'q': '¿Es seguro usar mi banca con la app?',
      'a': 'La app utiliza Firebase y prácticas estándar de seguridad, evita compartir tus credenciales.'
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
