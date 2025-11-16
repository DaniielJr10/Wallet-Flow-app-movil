
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Pantalla de Notas rediseñada para verse profesional y similar a la maqueta.
class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  // Cada nota se guarda como un mapa codificado en JSON: {"text":"...","date":"...","tags":[...]}
  List<Map<String, dynamic>> _notes = [];
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('notes') ?? [];
    setState(() {
      _notes = raw.map((s) {
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;
          return m;
        } catch (_) {
          return {"text": s, "date": DateTime.now().toIso8601String(), "tags": []};
        }
      }).toList();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _notes.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList('notes', raw);
  }

  void _addNote(String text, List<String> tags) {
    if (text.trim().isEmpty) return;
    final note = {"text": text.trim(), "date": DateTime.now().toIso8601String(), "tags": tags};
    setState(() {
      _notes.insert(0, note);
    });
    _saveNotes();
    _noteController.clear();
    _tagsController.clear();
    Navigator.of(context).pop();
  }

  void _editNote(int index, String newText, List<String> tags) {
    if (newText.trim().isEmpty) return;
    setState(() {
      _notes[index]['text'] = newText.trim();
      _notes[index]['tags'] = tags;
    });
    _saveNotes();
    _noteController.clear();
    _tagsController.clear();
    Navigator.of(context).pop();
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  void _showNoteDialog({int? index}) {
    if (index != null) {
      _noteController.text = _notes[index]['text'] ?? '';
      final tags = (_notes[index]['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      _tagsController.text = tags.join(', ');
    } else {
      _noteController.clear();
      _tagsController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        List<String> localTags = _tagsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: StatefulBuilder(builder: (context, setStateDialog) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(index == null ? 'Nueva nota' : 'Editar nota', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Note input
                    TextField(
                      controller: _noteController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu nota...',
                        filled: true,
                        fillColor: const Color(0xFFF7FAF7),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags input
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: 'Etiquetas (separadas por coma)',
                        filled: true,
                        fillColor: const Color(0xFFF7FAF7),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      onChanged: (v) {
                        setStateDialog(() {
                          localTags = v
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Tags preview
                    if (localTags.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: localTags
                              .map((t) => Chip(
                                    label: Text('#$t', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Cancelar')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            final tags = localTags;
                            if (index == null) {
                              _addNote(_noteController.text, tags);
                            } else {
                              _editNote(index, _noteController.text, tags);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      const months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notes.where((n) {
      final text = (n['text'] as String?) ?? '';
      final tags = ((n['tags'] as List<dynamic>?) ?? []).join(' ');
      final q = _search.toLowerCase();
      return q.isEmpty || text.toLowerCase().contains(q) || tags.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.note_alt_rounded, color: Color(0xFF10B981), size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Notas Financieras', style: TextStyle(color: Color(0xFF059669), fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Organiza y gestiona todas tus ideas y recordatorios financieros', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search + New note row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 8))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF10B981)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(hintText: 'Buscar en mis notas financieras...', border: InputBorder.none),
                              onChanged: (v) => setState(() => _search = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showNoteDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Nota'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Grid of note cards
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final cross = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final note = filtered[i];
                      final text = (note['text'] as String?) ?? '';
                      final tags = ((note['tags'] as List<dynamic>?) ?? []).cast<String>();
                      final date = (note['date'] as String?) ?? DateTime.now().toIso8601String();

                      return GestureDetector(
                        onTap: () => _showNoteDialog(index: _notes.indexOf(note)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))],
                            border: Border.all(color: const Color(0xFFE6F4EA)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // top row: tag pill + delete
                              Row(
                                children: [
                                  if (tags.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: const Color(0xFFEEF9F2), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6F4EA))),
                                      child: Row(children: [const Icon(Icons.label, size: 14, color: Color(0xFF10B981)), const SizedBox(width: 6), Text(tags.first, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700))]),
                                    )
                                  else
                                    Container(),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => _deleteNote(_notes.indexOf(note)),
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                text.length > 140 ? '${text.substring(0, 140)}...' : text,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  for (final t in tags.take(3))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                                      child: Text('#$t', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                    ),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(date), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
