import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Note: using timestamp-based ids to avoid adding new dependency

class RecordatorioGasto {
  final String id;
  String titulo;
  TimeOfDay hora;
  bool diario; // if true -> every day, otherwise weekly with days list
  List<int> diasSemana; // 1=Mon .. 7=Sun
  bool activo;

  RecordatorioGasto({
    required this.id,
    required this.titulo,
    required this.hora,
    this.diario = true,
    this.diasSemana = const [],
    this.activo = true,
  });

  factory RecordatorioGasto.fromJson(Map<String, dynamic> j) => RecordatorioGasto(
        id: j['id'] as String,
        titulo: j['titulo'] as String,
        hora: TimeOfDay(hour: j['hora_h'], minute: j['hora_m']),
        diario: j['diario'] as bool? ?? true,
        diasSemana: (j['diasSemana'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
        activo: j['activo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'hora_h': hora.hour,
        'hora_m': hora.minute,
        'diario': diario,
        'diasSemana': diasSemana,
        'activo': activo,
      };
}

class RecordatoriosGastosScreen extends StatefulWidget {
  const RecordatoriosGastosScreen({super.key});

  @override
  State<RecordatoriosGastosScreen> createState() => _RecordatoriosGastosScreenState();
}

class _RecordatoriosGastosScreenState extends State<RecordatoriosGastosScreen> {
  final List<RecordatorioGasto> _items = [];
  final _prefsKey = 'wf_recordatorios_gastos_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    setState(() {
      _items.clear();
      for (final s in raw) {
        try {
          final Map<String, dynamic> j = jsonDecode(s);
          _items.add(RecordatorioGasto.fromJson(j));
        } catch (_) {}
      }
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, data);
  }

  Future<void> _addOrEdit({RecordatorioGasto? existing}) async {
    final isNew = existing == null;
    final tituloCtrl = TextEditingController(text: existing?.titulo ?? 'Recordatorio de gastos');
    TimeOfDay hora = existing?.hora ?? const TimeOfDay(hour: 9, minute: 0);
    bool diario = existing?.diario ?? true;
    List<int> dias = List.from(existing?.diasSemana ?? []);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            Widget weekdayChips() {
              final nombres = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
              return Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final dia = i + 1;
                  final selected = dias.contains(dia);
                  return ChoiceChip(
                    label: Text(nombres[i]),
                    selected: selected,
                    selectedColor: const Color(0xFF10B981).withOpacity(0.15),
                    onSelected: (v) {
                      modalSetState(() {
                        if (v) dias.add(dia); else dias.remove(dia);
                      });
                    },
                  );
                }),
              );
            }

            return DraggableScrollableSheet(
              expand: false,
              builder: (_, controller) => Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                          ),
                                          child: const Icon(Icons.notifications, color: Colors.white, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(isNew ? 'Nuevo recordatorio' : 'Editar recordatorio', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                                  ],
                                ),
                      const SizedBox(height: 8),
                      TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text('Hora', style: TextStyle(color: Colors.grey[700]))),
                          TextButton(
                            child: Text(hora.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final t = await showTimePicker(context: context, initialTime: hora);
                              if (t != null) modalSetState(() => hora = t);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: diario,
                        title: const Text('Repetir diariamente'),
                        onChanged: (v) => modalSetState(() => diario = v),
                      ),
                      if (!diario) ...[
                        const SizedBox(height: 8),
                        const Text('Días de la semana', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        weekdayChips(),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final id = existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
                            if (isNew) {
                              _items.add(RecordatorioGasto(id: id, titulo: tituloCtrl.text.trim(), hora: hora, diario: diario, diasSemana: dias, activo: true));
                            } else {
                              // existing is non-null here
                              existing.titulo = tituloCtrl.text.trim();
                              existing.hora = hora;
                              existing.diario = diario;
                              existing.diasSemana = dias;
                            }
                            _save();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(isNew ? 'Crear recordatorio' : 'Guardar cambios'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleActivo(RecordatorioGasto r) async {
    r.activo = !r.activo;
    await _save();
    setState(() {});
  }

  Future<void> _eliminar(RecordatorioGasto r) async {
    _items.removeWhere((e) => e.id == r.id);
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios de gastos'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // show app logo if available
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Color(0xFFE6FFFA), Color(0xFFCFFAFE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: const Center(
                              child: Icon(Icons.notifications_none, size: 56, color: Color(0xFF10B981)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sin recordatorios',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Programa avisos para no olvidar tus gastos importantes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _addOrEdit(),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear recordatorio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = _items[i];
                        final timeText = r.hora.format(context);
                        final daysText = r.diario
                            ? 'Diario'
                            : r.diasSemana.map((d) => ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'][d-1]).join(', ');
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,6))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: r.activo ? const Color(0xFF10B981) : Colors.grey.shade300,
                              child: Text(
                                timeText,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: r.activo ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Chip(label: Text(daysText), backgroundColor: Colors.grey.shade100),
                                  Chip(label: Text(r.activo ? 'Activo' : 'Inactivo'), backgroundColor: r.activo ? const Color(0xFFECFDF5) : Colors.grey.shade50),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(value: r.activo, onChanged: (_) => _toggleActivo(r), activeColor: const Color(0xFF10B981)),
                                PopupMenuButton<String>(
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                    const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                  ],
                                  onSelected: (v) {
                                    if (v == 'edit') _addOrEdit(existing: r);
                                    if (v == 'delete') _eliminar(r);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addOrEdit(),
                icon: const Icon(Icons.add),
                label: const Text('Agregar recordatorio'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
