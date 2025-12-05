// 8. Formulario para crear o editar una meta de ahorro
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class FormularioMeta extends StatefulWidget {
  final bool esEdicion;
  final String? metaId;
  final Map<String, dynamic>? meta;
  final Function() onGuardarExitoso;

  const FormularioMeta({
    super.key,
    this.esEdicion = false,
    this.metaId,
    this.meta,
    required this.onGuardarExitoso,
  });

  @override
  State<FormularioMeta> createState() => _FormularioMetaState();
}

class _FormularioMetaState extends State<FormularioMeta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _montoInicialController = TextEditingController();
  final TextEditingController _montoObjetivoController = TextEditingController();
  DateTime? _fechaAhorro = DateTime.now();
  String _categoriaAhorro = 'vacaciones';
  final AhorrosServicio _ahorrosServicio = AhorrosServicio();

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion && widget.meta != null) {
      _nombreController.text = widget.meta!['nombre'] ?? '';
      _montoInicialController.text = FormatoNumeros.formatearParaMostrar(widget.meta!['montoInicial'] ?? 0.0);
      _montoObjetivoController.text = FormatoNumeros.formatearParaMostrar(widget.meta!['montoObjetivo'] ?? 0.0);
      _fechaAhorro = widget.meta!['fechaObjetivo'] is DateTime
          ? widget.meta!['fechaObjetivo']
          : (widget.meta!['fechaObjetivo'] is Timestamp 
              ? (widget.meta!['fechaObjetivo'] as Timestamp).toDate() 
              : DateTime.now());
      _categoriaAhorro = widget.meta!['categoria'] ?? 'vacaciones';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
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
            decoration: const BoxDecoration(
              color: UtilsAhorros.colorPrincipal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar ahorro' : 'Nuevo ahorro',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
                    const Text('Nombre del ahorro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombreController,
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa el nombre del ahorro' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsAhorros.colorPrincipal, width: 2)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Monto inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montoInicialController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FormateadorNumeros()],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa el monto inicial';
                        final monto = FormatoNumeros.convertirANumero(value);
                        if (monto == null || monto < 0) return 'Monto inválido';
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsAhorros.colorPrincipal, width: 2)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Monto objetivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montoObjetivoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FormateadorNumeros()],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa el monto objetivo';
                        final monto = FormatoNumeros.convertirANumero(value);
                        if (monto == null || monto <= 0) return 'Monto inválido';
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsAhorros.colorPrincipal, width: 2)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Fecha objetivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaAhorro ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          locale: const Locale('es', 'ES'),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: UtilsAhorros.colorPrincipal,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() => _fechaAhorro = picked);
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
                            const Icon(Icons.calendar_today_rounded, color: UtilsAhorros.colorPrincipal),
                            const SizedBox(width: 12),
                            Text(_fechaAhorro != null ? '${_fechaAhorro!.day}/${_fechaAhorro!.month}/${_fechaAhorro!.year}' : 'Selecciona una fecha'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _categoriaAhorro,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsAhorros.colorPrincipal, width: 2)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: UtilsAhorros.categorias.map((cat) => DropdownMenuItem<String>(
                        value: cat['valor'] as String,
                        child: Row(
                          children: [
                            Icon(cat['icono'], color: UtilsAhorros.colorPrincipal),
                            const SizedBox(width: 8),
                            Text(cat['nombre']),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _categoriaAhorro = val ?? 'vacaciones'),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UtilsAhorros.colorPrincipal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text(widget.esEdicion ? 'Actualizar cambios' : 'Guardar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      final montoInicial = FormatoNumeros.convertirANumero(_montoInicialController.text) ?? 0.0;
      final montoObjetivo = FormatoNumeros.convertirANumero(_montoObjetivoController.text) ?? 0.0;
      String? error;

      if (widget.esEdicion && widget.metaId != null) {
        error = await _ahorrosServicio.actualizarMetaAhorro(
          metaId: widget.metaId!,
          nombre: _nombreController.text.trim(),
          montoObjetivo: montoObjetivo,
          fechaObjetivo: _fechaAhorro ?? DateTime.now(),
          categoria: _categoriaAhorro,
        );
      } else {
        error = await _ahorrosServicio.crearMetaAhorro(
          nombre: _nombreController.text.trim(),
          montoInicial: montoInicial,
          montoObjetivo: montoObjetivo,
          fechaObjetivo: _fechaAhorro ?? DateTime.now(),
          categoria: _categoriaAhorro,
        );
      }

      if (error == null) {
        if (mounted) {
          Navigator.pop(context);
          widget.onGuardarExitoso();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.esEdicion ? 'Meta de ahorro actualizada correctamente' : 'Meta de ahorro creada correctamente'),
              backgroundColor: UtilsAhorros.colorPrincipal,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _montoInicialController.dispose();
    _montoObjetivoController.dispose();
    super.dispose();
  }
}