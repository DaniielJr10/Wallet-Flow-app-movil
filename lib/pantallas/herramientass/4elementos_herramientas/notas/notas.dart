/// ORQUESTADOR PRINCIPAL DE NOTAS
/// Gestiona el estado de la lista de notas, la comunicación con el servicio
/// de almacenamiento (SharedPreferences) y la coordinación de los componentes visuales.
import 'package:flutter/material.dart';

// Importaciones modularizadas
import 'funcionalidades/utils_notas.dart';
import 'funcionalidades/servicio_notas.dart';
import 'funcionalidades/app_bar_notas.dart';
import 'funcionalidades/header_notas.dart';
import 'funcionalidades/barra_busqueda_notas.dart';
import 'funcionalidades/grid_notas.dart';
import 'funcionalidades/dialogo_nota.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> with TickerProviderStateMixin {
  final ServicioNotas _servicioNotas = ServicioNotas();
  List<Map<String, dynamic>> _notes = [];
  String _search = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _cargarNotas();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarNotas() async {
    final notasCargadas = await _servicioNotas.cargarNotas();
    setState(() {
      _notes = notasCargadas;
    });
  }

  Future<void> _guardarCambios() async {
    await _servicioNotas.guardarNotas(_notes);
  }

  void _addNote(String text, List<String> tags) {
    if (text.trim().isEmpty) return;
    final note = {
      "text": text.trim(),
      "date": DateTime.now().toIso8601String(),
      "tags": tags
    };
    setState(() {
      _notes.insert(0, note);
    });
    _guardarCambios();
  }

  void _editNote(int index, String newText, List<String> tags) {
    if (newText.trim().isEmpty) return;
    setState(() {
      _notes[index]['text'] = newText.trim();
      _notes[index]['tags'] = tags;
    });
    _guardarCambios();
  }

  void _deleteNote(int index) {
    // Buscar la nota real en la lista principal usando el objeto, 
    // no el índice de la lista filtrada, para evitar borrar la incorrecta.
    // En esta implementación simple, pasamos el índice real desde el builder.
    setState(() {
      _notes.removeAt(index);
    });
    _guardarCambios();
  }

  void _mostrarDialogo({int? index}) {
    String? initialText;
    List<String> initialTags = [];

    if (index != null) {
      initialText = _notes[index]['text'];
      initialTags = (_notes[index]['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    }

    showDialog(
      context: context,
      builder: (context) => DialogoNota(
        esEdicion: index != null,
        initialText: initialText,
        initialTags: initialTags,
        onSave: (text, tags) {
          if (index != null) {
            _editNote(index, text, tags);
          } else {
            _addNote(text, tags);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrado de notas
    final filteredNotes = _notes.where((n) {
      final text = (n['text'] as String?) ?? '';
      final tags = ((n['tags'] as List<dynamic>?) ?? []).join(' ');
      final q = _search.toLowerCase();
      return q.isEmpty || text.toLowerCase().contains(q) || tags.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: UtilsNotas.colorFondo,
      appBar: const AppBarNotas(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderNotas(),
                const SizedBox(height: 20),
                BarraBusquedaNotas(
                  onSearchChanged: (v) => setState(() => _search = v),
                  onNewNote: () => _mostrarDialogo(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: filteredNotes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 80,
                                color: UtilsNotas.colorTextoGris.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _search.isEmpty ? 'No hay notas aún' : 'No se encontraron resultados',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: UtilsNotas.colorTextoGris,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _search.isEmpty
                                    ? 'Crea tu primera nota financiera'
                                    : 'Intenta con otra búsqueda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: UtilsNotas.colorTextoGris.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridNotas(
                          notasFiltradas: filteredNotes,
                          onTapNota: (i) {
                            final realIndex = _notes.indexOf(filteredNotes[i]);
                            _mostrarDialogo(index: realIndex);
                          },
                          onDeleteNota: (i) {
                            final realIndex = _notes.indexOf(filteredNotes[i]);
                            _deleteNote(realIndex);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}