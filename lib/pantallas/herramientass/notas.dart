
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Una pantalla de notas simple y moderna.
class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  // Lista para mantener las notas en memoria.
  List<String> _notes = [];
  // Controlador para el campo de texto del diálogo.
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga las notas guardadas cuando se inicia la pantalla.
    _loadNotes();
  }

  // Carga las notas desde SharedPreferences.
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Obtiene la lista de notas, o una lista vacía si no hay ninguna.
      _notes = prefs.getStringList('notes') ?? [];
    });
  }

  // Guarda la lista actual de notas en SharedPreferences.
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
  }

  // Añade una nueva nota a la lista.
  void _addNote(String note) {
    if (note.isNotEmpty) {
      setState(() {
        _notes.add(note);
      });
      _saveNotes(); // Guarda la lista actualizada.
      _noteController.clear(); // Limpia el controlador.
      Navigator.of(context).pop(); // Cierra el diálogo.
    }
  }

  // Edita una nota existente en la lista.
  void _editNote(int index, String newNote) {
    if (newNote.isNotEmpty) {
      setState(() {
        _notes[index] = newNote;
      });
      _saveNotes();
      _noteController.clear();
      Navigator.of(context).pop();
    }
  }

  // Elimina una nota de la lista.
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  // Muestra un diálogo para añadir o editar una nota.
  void _showNoteDialog({int? index}) {
    // Si se está editando, carga el texto de la nota en el controlador.
    if (index != null) {
      _noteController.text = _notes[index];
    } else {
      _noteController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Añadir Nota' : 'Editar Nota'),
          content: TextField(
            controller: _noteController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Escribe tu nota...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (index == null) {
                  _addNote(_noteController.text);
                } else {
                  _editNote(index, _noteController.text);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                'No hay notas todavía.\n¡Añade una!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    title: Text(_notes[index]),
                    onTap: () => _showNoteDialog(index: index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
