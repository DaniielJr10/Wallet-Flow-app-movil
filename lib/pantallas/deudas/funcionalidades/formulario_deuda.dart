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
    final primary = UtilsDeudas.colorPrincipal;
    final primaryDark = UtilsDeudas.colorSecundario;

    InputDecoration _fieldDecoration({String? label, Widget? prefix}) => InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryDark, width: 3)),
          filled: true,
          fillColor: Colors.grey.shade50,
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
                    // Título
                    const Text('Título', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: _fieldDecoration(label: 'Título'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      isExpanded: true,
                      decoration: _fieldDecoration(label: 'Categoría'),
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
                    const Text('Monto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(label: 'Monto', prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.attach_money_rounded, color: primary))),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Ingresa un monto válido' : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pago mínimo
                    const Text('Pago mínimo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pagoMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(label: 'Pago mínimo', prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.payments_rounded, color: primary))),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n < 0) ? 'Ingresa un pago mínimo válido' : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Acreedor
                    const Text('Acreedor / Banco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _acreedorCtrl,
                      decoration: _fieldDecoration(label: 'Acreedor / Banco', prefix: Padding(padding: const EdgeInsets.only(left:12,right:6), child: Icon(Icons.account_balance_rounded, color: primary))),
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    const Text('Fecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaVenc,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() { _fechaVenc = picked; });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text('${_fechaVenc.day}/${_fechaVenc.month}/${_fechaVenc.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),

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
                            child: Text(widget.esEdicion ? 'Guardar Cambios' : 'Crear', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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