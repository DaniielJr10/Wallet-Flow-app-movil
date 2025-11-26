/// FORMULARIO DE NOTA
/// Diálogo modal para crear o editar una nota. Gestiona los controladores
/// de texto y etiquetas localmente y devuelve los datos al cerrarse.
import 'package:flutter/material.dart';
import 'utils_notas.dart';

class DialogoNota extends StatefulWidget {
  final String? initialText;
  final List<String> initialTags;
  final bool esEdicion;
  final Function(String text, List<String> tags) onSave;

  const DialogoNota({
    super.key,
    this.initialText,
    this.initialTags = const [],
    required this.esEdicion,
    required this.onSave,
  });

  @override
  State<DialogoNota> createState() => _DialogoNotaState();
}

class _DialogoNotaState extends State<DialogoNota> {
  late TextEditingController _noteController;
  late TextEditingController _tagsController;
  List<String> _localTags = [];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialText ?? '');
    _tagsController = TextEditingController(text: widget.initialTags.join(', '));
    _localTags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateTags(String value) {
    setState(() {
      _localTags = value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    widget.esEdicion ? 'Editar nota' : 'Nueva nota',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  )
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
                  fillColor: UtilsNotas.colorInputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tags input
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'Etiquetas (separadas por coma)',
                  filled: true,
                  fillColor: UtilsNotas.colorInputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                onChanged: _updateTags,
              ),
              const SizedBox(height: 10),

              // Tags preview
              if (_localTags.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _localTags
                        .map((t) => Chip(
                              label: Text('#$t', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              backgroundColor: const Color(0xFFF3F4F6),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 14),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_noteController.text, _localTags);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UtilsNotas.colorPrincipal,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}