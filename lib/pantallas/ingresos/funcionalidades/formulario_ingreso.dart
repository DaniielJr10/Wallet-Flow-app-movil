/// FORMULARIO DE GESTIÓN
/// BottomSheet para Crear y Editar ingresos. Gestiona validaciones de campos,
/// selectores de fecha y comunicación con los servicios de Firebase.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/ingresoService/ingresos_servicio.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ingresos.dart';

class FormularioIngreso extends StatefulWidget {
  final bool esEdicion;
  final Map<String, dynamic>? ingresoExistente;
  final VoidCallback onGuardar;

  const FormularioIngreso({
    super.key,
    this.esEdicion = false,
    this.ingresoExistente,
    required this.onGuardar,
  });

  @override
  State<FormularioIngreso> createState() => _FormularioIngresoState();
}

class _FormularioIngresoState extends State<FormularioIngreso> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final IngresosServicio _ingresosServicio = IngresosServicio();
  final CuentasServicio _cuentasServicio = CuentasServicio();

  DateTime _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'trabajo';
  String _metodoPagoSeleccionado = 'Efectivo';
  String _cuentaAsociada = 'ninguna';

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion && widget.ingresoExistente != null) {
      final ing = widget.ingresoExistente!;
      _montoController.text = FormatoNumeros.formatearParaMostrar(ing['monto']);
      _descripcionController.text = ing['descripcion'];
      _fechaSeleccionada = ing['fecha'];
      _categoriaSeleccionada = ing['categoria'];
      _metodoPagoSeleccionado = ing['metodoPago'];
      _cuentaAsociada = ing['cuentaAsociada'] ?? 'ninguna';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [UtilsIngresos.colorPrincipal, UtilsIngresos.colorSecundario],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar Ingreso' : 'Nuevo Ingreso',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
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
                    _buildCampoMonto(),
                    const SizedBox(height: 20),
                    _buildCampoDescripcion(),
                    const SizedBox(height: 20),
                    _buildSelectorFecha(),
                    const SizedBox(height: 20),
                    _buildSelectorCategoria(),
                    const SizedBox(height: 20),
                    _buildSelectorMetodoPago(),
                    const SizedBox(height: 20),
                    _buildSelectorCuentaAsociada(),
                    const SizedBox(height: 32),
                    _buildBotonesAccion(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoMonto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FormateadorNumeros()],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa el monto';
            if ((FormatoNumeros.convertirANumero(v) ?? 0) <= 0) return 'Monto inválido';
            return null;
          },
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: UtilsIngresos.colorPrincipal, width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildCampoDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          validator: (v) => (v == null || v.isEmpty) ? 'Ingresa una descripción' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: UtilsIngresos.colorPrincipal, width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _fechaSeleccionada, firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (picked != null) setState(() => _fechaSeleccionada = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: UtilsIngresos.colorPrincipal, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: UtilsIngresos.colorPrincipal),
                const SizedBox(width: 12),
                Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCategoria() {
    return _buildDropdown(
      'Categoría',
      _categoriaSeleccionada,
      UtilsIngresos.categorias,
      (v) => setState(() => _categoriaSeleccionada = v!),
    );
  }

  Widget _buildSelectorMetodoPago() {
    return _buildDropdown(
      'Método de Pago',
      _metodoPagoSeleccionado,
      UtilsIngresos.metodosPago,
      (v) => setState(() => _metodoPagoSeleccionado = v!),
    );
  }

  Widget _buildSelectorCuentaAsociada() {
    return StreamBuilder<QuerySnapshot>(
      stream: _cuentasServicio.obtenerCuentas(),
      builder: (context, snapshot) {
        List<DropdownMenuItem<String>> items = [
          const DropdownMenuItem(value: 'ninguna', child: Text('Ninguna')),
        ];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['activa'] != false) {
              items.add(DropdownMenuItem(value: doc.id, child: Text('${data['banco']} - ${data['numeroCuenta']}')));
            }
          }
        }
        // Validar valor actual
        if (!items.any((i) => i.value == _cuentaAsociada)) _cuentaAsociada = 'ninguna';
        
        return _buildDropdown('Cuenta Asociada', _cuentaAsociada, [], (v) => setState(() => _cuentaAsociada = v!), customItems: items);
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged, {List<DropdownMenuItem<String>>? customItems}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: customItems ?? items.map((e) => DropdownMenuItem(value: e, child: Text(UtilsIngresos.capitalizar(e)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: UtilsIngresos.colorPrincipal, width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: UtilsIngresos.colorPrincipal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(widget.esEdicion ? 'Actualizar' : 'Guardar'),
          ),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0.0;
      
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      try {
        String? error;
        if (widget.esEdicion && widget.ingresoExistente != null) {
          error = await _ingresosServicio.actualizarIngreso(
            ingresoId: widget.ingresoExistente!['id'],
            monto: monto,
            fecha: _fechaSeleccionada,
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
            metodoPago: _metodoPagoSeleccionado,
            cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          );
        } else {
          error = await _ingresosServicio.registrarIngreso(
            monto: monto,
            fecha: _fechaSeleccionada,
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
            metodoPago: _metodoPagoSeleccionado,
            cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          );
        }
        
        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          if (error == null) {
            Navigator.pop(context); // Cerrar form
            widget.onGuardar();
          } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
      }
    }
  }
}