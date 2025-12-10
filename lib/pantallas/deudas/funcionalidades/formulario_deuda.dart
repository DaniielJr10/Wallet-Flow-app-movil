// Formulario unificado para crear y editar deudas.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils_deudas.dart';

class FormularioDeuda extends StatefulWidget {
  final bool esEdicion;
  final Map<String, dynamic>? deudaExistente;
  final VoidCallback onGuardar;

  const FormularioDeuda({
    super.key,
    this.esEdicion = false,
    this.deudaExistente,
    required this.onGuardar,
  });

  @override
  State<FormularioDeuda> createState() => _FormularioDeudaState();
}

class _FormularioDeudaState extends State<FormularioDeuda> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _montoCtrl;
  late TextEditingController _acreedorCtrl;
  late String _tipoSeleccionado;
  late DateTime _fechaVenc;
  bool _tieneRecordatorio = false;
  DateTime? _fechaRecordatorio;

  @override
  void initState() {
    super.initState();
    final deuda = widget.deudaExistente ?? {};
    _tituloCtrl = TextEditingController(text: deuda['titulo'] ?? '');
    _montoCtrl = TextEditingController(text: (deuda['montoOriginal'] ?? deuda['montoPendiente'] ?? '').toString());
    _acreedorCtrl = TextEditingController(text: deuda['acreedor'] ?? '');
    _tipoSeleccionado = deuda['tipo'] ?? 'Préstamo Personal';
    _fechaVenc = deuda['fechaVencimiento'] ?? DateTime.now().add(const Duration(days: 30));
    if (deuda.containsKey('recordatorio') && deuda['recordatorio'] != null) {
      final r = deuda['recordatorio'];
      if (r is Timestamp) _fechaRecordatorio = r.toDate();
      else if (r is DateTime) _fechaRecordatorio = r;
      if (_fechaRecordatorio != null) _tieneRecordatorio = true;
    }
    // Eliminado manejo de frecuencia
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _montoCtrl.dispose();
    _acreedorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = UtilsDeudas.colorPrincipal;
    InputDecoration _fieldDecoration({String? label, Widget? prefix}) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefix,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsDeudas.colorPrincipal, UtilsDeudas.colorSecundario],
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar Deuda' : 'Nueva Deuda',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white24, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    const Text('Nombre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: _fieldDecoration(prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.label_outline, color: primary))),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    // Categoría
                    const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      isExpanded: true,
                      decoration: _fieldDecoration(prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.category_outlined, color: primary))),
                      items: const [
                        DropdownMenuItem(value: 'Préstamo Personal', child: Text('Préstamo Personal')),
                        DropdownMenuItem(value: 'Tarjeta de Crédito', child: Text('Tarjeta de Crédito')),
                        DropdownMenuItem(value: 'Préstamo Vehicular', child: Text('Préstamo Vehicular')),
                        DropdownMenuItem(value: 'Préstamo Hipotecario', child: Text('Préstamo Hipotecario')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) => setState(() { _tipoSeleccionado = v ?? _tipoSeleccionado; }),
                    ),
                    const SizedBox(height: 16),
                    // Monto
                    const Text('Monto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.attach_money_rounded, color: primary))),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Ingresa un monto válido' : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Prestamista
                    const Text('Prestamista', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _acreedorCtrl,
                      decoration: _fieldDecoration(prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.person_outline, color: primary))),
                    ),
                    const SizedBox(height: 16),
                    // Fecha
                    const Text('Fecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaVenc,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          locale: const Locale('es', 'ES'),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() { _fechaVenc = picked; });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: primary, size: 20),
                            const SizedBox(width: 12),
                            Text('${_fechaVenc.day}/${_fechaVenc.month}/${_fechaVenc.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Recordatorio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recordatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                        Switch(value: _tieneRecordatorio, onChanged: (v) => setState(() { _tieneRecordatorio = v; if (!v) _fechaRecordatorio = null; if (v && _fechaRecordatorio == null) _fechaRecordatorio = DateTime.now().add(const Duration(days:1)); })),
                      ],
                    ),
                    if (_tieneRecordatorio) ...[
                      const SizedBox(height:8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _fechaRecordatorio ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            locale: const Locale('es', 'ES'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: primary,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_fechaRecordatorio ?? DateTime.now()),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: primary,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time == null) return;
                          setState(() {
                            _fechaRecordatorio = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications, color: primary),
                              const SizedBox(width: 12),
                              Text(
                                _fechaRecordatorio != null
                                  ? '${_fechaRecordatorio!.day}/${_fechaRecordatorio!.month}/${_fechaRecordatorio!.year} ${_fechaRecordatorio!.hour.toString().padLeft(2, '0')}:${_fechaRecordatorio!.minute.toString().padLeft(2, '0')}'
                                  : 'Seleccionar fecha y hora',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UtilsDeudas.colorPrincipal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: Text(widget.esEdicion ? 'Actualizar cambios' : 'Guardar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() ?? false) {
      final monto = double.tryParse(_montoCtrl.text) ?? 0.0;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        String? error;
        // Guardar deuda normal (sin frecuencia)
        error = null; // Aquí deberías llamar al servicio que guarda la deuda normal
        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          if (error == null) {
            Navigator.pop(context); // Cerrar form
            widget.onGuardar();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}