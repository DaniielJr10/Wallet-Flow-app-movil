import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utilidades/formato_numeros.dart';
import '../../../../firebase/servicios/ingresos_servicio.dart';
import '../../../../firebase/servicios/cuentas_servicio.dart';
import 'utils_ingresos.dart';

class FormularioIngresoModal extends StatefulWidget {
  final Map<String, dynamic>? ingresoAEditar;

  const FormularioIngresoModal({super.key, this.ingresoAEditar});

  @override
  State<FormularioIngresoModal> createState() => _FormularioIngresoModalState();
}

class _FormularioIngresoModalState extends State<FormularioIngresoModal> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final IngresosServicio _ingresosServicio = IngresosServicio();
  final CuentasServicio _cuentasServicio = CuentasServicio();

  DateTime _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'trabajo';
  String _metodoPagoSeleccionado = 'Efectivo';
  String _cuentaAsociada = 'ninguna';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingresoAEditar != null) {
      _montoController.text = FormatoNumeros.formatearParaMostrar(widget.ingresoAEditar!['monto']);
      _descripcionController.text = widget.ingresoAEditar!['descripcion'];
      final fecha = widget.ingresoAEditar!['fecha'];
      _fechaSeleccionada = fecha is Timestamp ? fecha.toDate() : fecha as DateTime;
      _categoriaSeleccionada = widget.ingresoAEditar!['categoria'];
      _metodoPagoSeleccionado = widget.ingresoAEditar!['metodoPago'];
      _cuentaAsociada = widget.ingresoAEditar!['cuentaAsociada'] ?? 'ninguna';
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarIngreso() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0;
        String? error;

        if (widget.ingresoAEditar != null) {
          error = await _ingresosServicio.actualizarIngreso(
            ingresoId: widget.ingresoAEditar!['id'],
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
          if (error != null) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.ingresoAEditar != null ? 'Ingreso actualizado' : 'Ingreso registrado'),
                backgroundColor: widget.ingresoAEditar != null ? Colors.blue.shade600 : Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )
            );
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.ingresoAEditar != null;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    esEdicion ? 'Editar Ingreso' : 'Nuevo Ingreso',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  // ... Widgets auxiliares (Monto, Descripcion, Fecha, Categoria, MetodoPago) similares a tu codigo ...
  // Por brevedad, he omitido los widgets más simples para concentrarme en la logica compleja abajo

  Widget _buildCampoMonto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FormateadorNumeros()],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingresa el monto';
            final monto = FormatoNumeros.convertirANumero(value);
            if (monto == null || monto <= 0) return 'Ingresa un monto válido mayor a 0';
            return null;
          },
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 3)),
            filled: true, fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildCampoDescripcion() {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          validator: (value) => value == null || value.isEmpty ? 'Por favor ingresa una descripción' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 3)),
            filled: true, fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2ecc71), width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0xFF2ecc71), size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCategoria() {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 3)),
            filled: true, fillColor: Colors.grey.shade50,
          ),
          items: UtilsIngresos.categorias.map((categoria) {
            return DropdownMenuItem(
              value: categoria,
              child: Row(children: [
                Icon(UtilsIngresos.getIconoCategoria(categoria), color: const Color(0xFF2ecc71), size: 20),
                const SizedBox(width: 12),
                Text(categoria.substring(0, 1).toUpperCase() + categoria.substring(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ]),
            );
          }).toList(),
          onChanged: (value) => setState(() => _categoriaSeleccionada = value!),
        ),
      ],
    );
  }

  Widget _buildSelectorMetodoPago() {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Método de Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _metodoPagoSeleccionado,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 3)),
            filled: true, fillColor: Colors.grey.shade50,
          ),
          items: UtilsIngresos.metodosPago.map((metodo) {
            return DropdownMenuItem(
              value: metodo,
              child: Row(children: [
                Icon(metodo == 'Efectivo' ? Icons.money_rounded : Icons.credit_card_rounded, color: const Color(0xFF2ecc71), size: 20),
                const SizedBox(width: 12),
                Text(metodo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ]),
            );
          }).toList(),
          onChanged: (value) => setState(() => _metodoPagoSeleccionado = value!),
        ),
      ],
    );
  }

  // AQUI ESTA LA LOGICA COMPLEJA DEL SELECTOR DE CUENTAS QUE ME PASASTE EN LA PARTE 2
  Widget _buildSelectorCuentaAsociada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cuenta Asociada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: _cuentasServicio.obtenerCuentas(),
          builder: (context, snapshot) {
            List<DropdownMenuItem<String>> items = [
              const DropdownMenuItem(
                value: 'ninguna',
                child: Row(children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2ecc71), size: 20),
                    SizedBox(width: 12),
                    Text('Ninguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ]),
              ),
            ];
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              items.add(const DropdownMenuItem(value: 'cargando', child: Text('Cargando cuentas...', style: TextStyle(fontSize: 16, color: Colors.grey))));
            } else if (snapshot.hasError) {
              items.add(const DropdownMenuItem(value: 'error', child: Text('Error al cargar cuentas', style: TextStyle(fontSize: 16, color: Colors.red))));
            } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
              for (var doc in snapshot.data!.docs) {
                try {
                  final cuenta = doc.data() as Map<String, dynamic>?;
                  if (cuenta != null) {
                    final activa = cuenta['activa'] as bool? ?? true;
                    if (!activa) continue;
                    
                    final banco = cuenta['banco']?.toString() ?? 'Banco';
                    final numero = cuenta['numeroCuenta']?.toString() ?? 'Sin número';
                    final alias = cuenta['alias']?.toString();
                    final cuentaId = doc.id;
                    
                    String displayName = (alias != null && alias.isNotEmpty) ? '$alias ($banco)' : '$banco - $numero';
                    
                    items.add(DropdownMenuItem(
                      value: cuentaId,
                      child: Row(children: [
                          const Icon(Icons.account_balance, color: Color(0xFF2ecc71), size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      ]),
                    ));
                  }
                } catch (e) { continue; }
              }
            }
            
            final validValues = items.map((item) => item.value).toSet();
            if (!validValues.contains(_cuentaAsociada)) _cuentaAsociada = 'ninguna';
            
            return DropdownButtonFormField<String>(
              value: _cuentaAsociada,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ecc71), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 3)),
                filled: true, fillColor: Colors.grey.shade50,
              ),
              items: items,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != _cuentaAsociada && newValue != 'cargando' && newValue != 'error') {
                  setState(() => _cuentaAsociada = newValue);
                }
              },
            );
          },
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarIngreso,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ecc71),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(widget.ingresoAEditar != null ? 'Actualizar' : 'Guardar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}