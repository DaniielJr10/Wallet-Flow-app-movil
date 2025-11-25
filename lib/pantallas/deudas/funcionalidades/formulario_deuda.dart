// Formulario unificado para crear y editar deudas.
import 'package:flutter/material.dart';
import '../../../firebase/servicios/deudas_servicio.dart';
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
  final DeudasServicio _deudasServicio = DeudasServicio();
  
  late TextEditingController _tituloCtrl;
  late TextEditingController _montoCtrl;
  late TextEditingController _pagoMinCtrl;
  late TextEditingController _acreedorCtrl;
  late String _tipoSeleccionado;
  late DateTime _fechaVenc;

  @override
  void initState() {
    super.initState();
    final deuda = widget.deudaExistente ?? {};
    
    _tituloCtrl = TextEditingController(text: deuda['titulo'] ?? '');
    _montoCtrl = TextEditingController(text: (deuda['montoOriginal'] ?? deuda['montoPendiente'] ?? '').toString());
    _pagoMinCtrl = TextEditingController(text: (deuda['pagoMinimo'] ?? '').toString());
    _acreedorCtrl = TextEditingController(text: deuda['acreedor'] ?? '');
    _tipoSeleccionado = deuda['tipo'] ?? 'Préstamo Personal';
    _fechaVenc = deuda['fechaVencimiento'] ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _montoCtrl.dispose();
    _pagoMinCtrl.dispose();
    _acreedorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UtilsDeudas.colorPrincipal.withOpacity(0.95),
                  UtilsDeudas.colorSecundario.withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.esEdicion ? Icons.edit : Icons.receipt_long, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar Deuda' : 'Crear Deuda',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'Préstamo Personal', child: Text('Préstamo Personal')),
                        DropdownMenuItem(value: 'Tarjeta de Crédito', child: Text('Tarjeta de Crédito')),
                        DropdownMenuItem(value: 'Préstamo Vehicular', child: Text('Préstamo Vehicular')),
                        DropdownMenuItem(value: 'Préstamo Hipotecario', child: Text('Préstamo Hipotecario')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) => setState(() { _tipoSeleccionado = v ?? _tipoSeleccionado; }),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _montoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Ingresa un monto válido' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pagoMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pago mínimo',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n < 0) ? 'Ingresa un pago mínimo válido' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _acreedorCtrl,
                      decoration: InputDecoration(
                        labelText: 'Acreedor / Banco',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Fecha de vencimiento:'),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaVenc,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() { _fechaVenc = picked; });
                          },
                          child: Text('${_fechaVenc.day}/${_fechaVenc.month}/${_fechaVenc.year}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardar,
                            child: Text(widget.esEdicion ? 'Guardar Cambios' : 'Crear'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UtilsDeudas.colorPrincipal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() ?? false) {
      final monto = double.tryParse(_montoCtrl.text) ?? 0.0;
      final pagoMin = double.tryParse(_pagoMinCtrl.text) ?? 0.0;
      
      if (widget.esEdicion) {
        final datosActualizados = {
          'titulo': _tituloCtrl.text.trim(),
          'montoOriginal': monto,
          'montoPendiente': monto, // Nota: Esto resetea el pendiente al original si se edita, ajustar según lógica deseada
          'pagoMinimo': pagoMin,
          'acreedor': _acreedorCtrl.text.trim(),
          'tipo': _tipoSeleccionado,
          'fechaVencimiento': _fechaVenc,
        };
        await _deudasServicio.editarDeuda(widget.deudaExistente!['id'], datosActualizados);
      } else {
        final nuevaDeuda = {
          'titulo': _tituloCtrl.text.trim(),
          'tipo': _tipoSeleccionado,
          'montoOriginal': monto,
          'montoPendiente': monto,
          'tasaInteres': 0.0,
          'fechaVencimiento': _fechaVenc,
          'pagoMinimo': pagoMin,
          'estado': 'Pendiente',
          'fechaCreacion': DateTime.now(),
          'acreedor': _acreedorCtrl.text.trim(),
          'numeroCuenta': '',
          'historialPagos': [],
        };
        await _deudasServicio.crearDeuda(nuevaDeuda);
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onGuardar();
      }
    }
  }
}