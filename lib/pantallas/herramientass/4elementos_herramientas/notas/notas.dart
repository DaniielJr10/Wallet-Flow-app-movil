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

  // La sincronización se maneja por operación (crear/actualizar/eliminar) directamente en Firestore.

  Future<void> _addNote(String text, List<String> tags) async {
    if (text.trim().isEmpty) return;
    final creada = await _servicioNotas.crearNota(
      texto: text.trim(),
      etiquetas: tags,
    );
    if (creada != null) {
      setState(() {
        _notes.insert(0, creada);
      });
    }
  }

  Future<void> _editNote(int index, String newText, List<String> tags) async {
    if (newText.trim().isEmpty) return;
    final nota = _notes[index];
    final id = nota['id'] as String?;
    if (id == null || id.isEmpty) {
      // Si no tiene id (caso raro), crear en BD en vez de duplicar
      await _addNote(newText, tags);
      return;
    }
    final actualizado = {
      ...nota,
      'id': id,
      'text': newText.trim(),
      'tags': tags,
    };
    final ok = await _servicioNotas.actualizarNota(actualizado);
    if (ok) {
      setState(() {
        _notes[index] = actualizado;
      });
    }
  }

  Future<void> _deleteNote(int index) async {
    // Buscar la nota real en la lista principal usando el objeto, 
    // no el índice de la lista filtrada, para evitar borrar la incorrecta.
    // En esta implementación simple, pasamos el índice real desde el builder.
    final id = _notes[index]['id'] as String?;
    if (id != null && id.isNotEmpty) {
      final ok = await _servicioNotas.eliminarNotaPorId(id);
      if (!ok) return;
    }
    setState(() {
      _notes.removeAt(index);
    });
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
                          onDeleteNota: (i) async {
                            final realIndex = _notes.indexOf(filteredNotes[i]);
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text('¿Borrar nota?'),
                                  content: const Text('¿Seguro que deseas borrar esta nota? Esta acción no se puede deshacer.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Borrar'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmar == true) {
                              await _deleteNote(realIndex);
                            }
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