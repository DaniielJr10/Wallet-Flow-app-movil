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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                UtilsNotas.colorInputBg,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: UtilsNotas.colorBorde, width: 2),
            boxShadow: [
              BoxShadow(
                color: UtilsNotas.colorPrincipal.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header mejorado con gradiente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [UtilsNotas.colorPrincipal, UtilsNotas.colorSecundario],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.esEdicion ? Icons.edit_note_rounded : Icons.note_add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.esEdicion ? 'Editar nota' : 'Nueva nota',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Note input mejorado con borde y sombra
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UtilsNotas.colorBorde, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: UtilsNotas.colorPrincipal.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu nota aquí...',
                      hintStyle: TextStyle(color: UtilsNotas.colorTextoGris.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Tags input mejorado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UtilsNotas.colorBorde, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: UtilsNotas.colorPrincipal.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText: 'Etiquetas (separadas por coma)',
                      hintStyle: TextStyle(color: UtilsNotas.colorTextoGris.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.label_rounded, color: UtilsNotas.colorPrincipal),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: _updateTags,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Tags preview mejorado con gradientes
                if (_localTags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: UtilsNotas.colorTagBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: UtilsNotas.colorBorde),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _localTags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      UtilsNotas.colorPrincipal.withOpacity(0.15),
                                      UtilsNotas.colorSecundario.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: UtilsNotas.colorPrincipal.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.label_rounded, size: 14, color: UtilsNotas.colorAccento),
                                    const SizedBox(width: 6),
                                    Text(
                                      '#$t',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: UtilsNotas.colorAccento,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 24),

                // Botones mejorados con diseño moderno
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: UtilsNotas.colorTextoGris.withOpacity(0.3), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: UtilsNotas.colorTextoGris,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSave(_noteController.text, _localTags);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UtilsNotas.colorPrincipal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: UtilsNotas.colorPrincipal.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Guardar',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ],
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
    );
  }
}