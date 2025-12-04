// FormularioGasto: Formulario para crear o editar un gasto de forma avanzada.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/gastoService/gastos_servicio.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_gastos.dart';
import 'frecuencia.dart';

class FormularioGasto extends StatefulWidget {
  final bool esEdicion;
  final Map<String, dynamic>? gastoExistente;
  final VoidCallback onGuardar;

  const FormularioGasto({
    super.key,
    this.esEdicion = false,
    this.gastoExistente,
    required this.onGuardar,
  });

  @override
  State<FormularioGasto> createState() => _FormularioGastoState();
}

class _FormularioGastoState extends State<FormularioGasto> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final GastosServicio _gastosServicio = GastosServicio();
  final CuentasServicio _cuentasServicio = CuentasServicio();

  DateTime _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'alimentación';
  String _metodoPagoSeleccionado = 'efectivo';
  String _cuentaAsociada = 'ninguna';
  TipoFrecuencia _frecuencia = TipoFrecuencia.ninguna;
  TipoFrecuencia _frecuenciaOriginal = TipoFrecuencia.ninguna;
  bool _tieneRecordatorio = false;
  DateTime? _fechaRecordatorio;

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion && widget.gastoExistente != null) {
      final g = widget.gastoExistente!;
      _montoController.text = FormatoNumeros.formatearParaMostrar(g['monto']);
      _descripcionController.text = g['descripcion'] ?? '';
      _fechaSeleccionada = g['fecha'] ?? DateTime.now();
      _categoriaSeleccionada = g['categoria'] ?? 'alimentación';
      _metodoPagoSeleccionado = g['metodoPago'] ?? 'efectivo';
      _cuentaAsociada = g['cuentaAsociada'] ?? 'ninguna';
      // Obtener frecuencia del gasto existente
      if (g.containsKey('frecuencia') && g['frecuencia'] != null) {
        _frecuencia = FrecuenciaUtils.desdeString(g['frecuencia']) ?? TipoFrecuencia.ninguna;
      } else {
        _frecuencia = TipoFrecuencia.ninguna;
      }
      _frecuenciaOriginal = _frecuencia;
      if (g.containsKey('recordatorio') && g['recordatorio'] != null) {
        final r = g['recordatorio'];
        if (r is Timestamp) {
          _tieneRecordatorio = true;
          _fechaRecordatorio = r.toDate();
        } else if (r is DateTime) {
          _tieneRecordatorio = true;
          _fechaRecordatorio = r;
        }
      }
    }
    // Validar que la cuenta asociada existe después de inicializar
    _validarCuentaAsociada();
  }

  // Método para validar que la cuenta asociada aún existe
  void _validarCuentaAsociada() async {
    if (_cuentaAsociada != 'ninguna') {
      try {
        final cuentaDoc = await _cuentasServicio.obtenerCuentaPorId(_cuentaAsociada);
        if (cuentaDoc == null || !cuentaDoc.exists) {
          // Si la cuenta no existe, cambiar a 'ninguna'
          if (mounted) {
            setState(() {
              _cuentaAsociada = 'ninguna';
            });
          }
        } else {
          final data = cuentaDoc.data() as Map<String, dynamic>?;
          if (data != null && data['activa'] == false) {
            // Si la cuenta está inactiva, mantener el ID para mostrar como eliminada
            // El dropdown manejará esto adecuadamente
          }
        }
      } catch (e) {
        // En caso de error, cambiar a 'ninguna'
        if (mounted) {
          setState(() {
            _cuentaAsociada = 'ninguna';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                colors: [UtilsGastos.colorPrincipal, UtilsGastos.colorSecundario],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.esEdicion ? Icons.edit_rounded : Icons.payment_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar Gasto' : 'Nuevo Gasto',
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
                    _buildInput(
                      controller: _montoController,
                      label: 'Monto *',
                      hint: '0.00',
                      isNumber: true,
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(height: 20),
                    _buildInput(
                      controller: _descripcionController,
                      label: 'Descripción *',
                      hint: 'Ej: Supermercado...',
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 20),
                    _buildSelectorFecha(),
                    const SizedBox(height: 20),
                    _buildDropdown('Categoría', _categoriaSeleccionada, UtilsGastos.categorias, (v) => setState(() => _categoriaSeleccionada = v!)),
                    const SizedBox(height: 20),
                    _buildDropdown('Método de Pago', _metodoPagoSeleccionado, UtilsGastos.metodosPago, (v) => setState(() => _metodoPagoSeleccionado = v!)),
                    const SizedBox(height: 20),
                    _buildSelectorCuenta(),
                    const SizedBox(height: 20),
                    SelectorFrecuencia(
                      frecuenciaActual: _frecuencia,
                      onCambio: (frecuencia) {
                        setState(() {
                          _frecuencia = frecuencia;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildRecordatorio(),
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
                              backgroundColor: UtilsGastos.colorPrincipal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildRecordatorio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recordatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Switch(
              value: _tieneRecordatorio,
              onChanged: (v) => setState(() {
                _tieneRecordatorio = v;
                if (!v) _fechaRecordatorio = null;
                if (v && _fechaRecordatorio == null) _fechaRecordatorio = DateTime.now().add(const Duration(days:1));
              }),
            ),
          ],
        ),
        if (_tieneRecordatorio) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(context: context, initialDate: _fechaRecordatorio ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
              if (pickedDate == null) return;
              final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_fechaRecordatorio ?? DateTime.now()));
              if (pickedTime == null) return;
              setState(() {
                _fechaRecordatorio = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
              child: Row(children: [Icon(Icons.notifications, color: UtilsGastos.colorPrincipal), const SizedBox(width:12), Text(_fechaRecordatorio != null ? '${_fechaRecordatorio!.day}/${_fechaRecordatorio!.month}/${_fechaRecordatorio!.year} ${_fechaRecordatorio!.hour.toString().padLeft(2,'0')}:${_fechaRecordatorio!.minute.toString().padLeft(2,'0')}' : 'Seleccionar fecha y hora')]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, required String hint, bool isNumber = false, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FormateadorNumeros()] : [],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Campo requerido';
            if (isNumber && (FormatoNumeros.convertirANumero(v) ?? 0) <= 0) return 'Monto inválido';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: UtilsGastos.colorPrincipal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsGastos.colorPrincipal, width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(UtilsGastos.capitalizar(e)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: UtilsGastos.colorPrincipal, width: 2)),
            filled: true,
            fillColor: Colors.white,
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
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _fechaSeleccionada, firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (picked != null) setState(() => _fechaSeleccionada = picked);
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
                Icon(Icons.calendar_today_rounded, color: UtilsGastos.colorPrincipal),
                const SizedBox(width: 12),
                Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCuenta() {
    return StreamBuilder<QuerySnapshot>(
      stream: _cuentasServicio.obtenerCuentas(),
      builder: (context, snapshot) {
        List<DropdownMenuItem<String>> items = [
          const DropdownMenuItem(value: 'ninguna', child: Text('Ninguna')),
        ];
        List<DropdownMenuItem<String>> dineroEnManoItems = [];
        List<DropdownMenuItem<String>> bancariasItems = [];
        bool cuentaAsociadaEnLista = false;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['activa'] == true) {
              if (data['tipo'] == 'dinero_en_mano') {
                dineroEnManoItems.add(DropdownMenuItem(value: doc.id, child: const Text('Dinero en mano')));
              } else {
                bancariasItems.add(DropdownMenuItem(value: doc.id, child: Text('${data['banco']} - ${data['numeroCuenta']}')));
              }
              if (doc.id == _cuentaAsociada) cuentaAsociadaEnLista = true;
            }
          }
        }
        items.addAll(dineroEnManoItems);
        items.addAll(bancariasItems);
        // Si la cuenta asociada no está en la lista de cuentas activas, verificar si fue eliminada
        if (_cuentaAsociada != 'ninguna' && !cuentaAsociadaEnLista) {
          return FutureBuilder(
            future: _cuentasServicio.obtenerCuentaPorId(_cuentaAsociada),
            builder: (context, snapCuenta) {
              if (snapCuenta.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapCuenta.hasData && snapCuenta.data != null && snapCuenta.data!.exists) {
                // La cuenta existe pero está inactiva o eliminada
                final data = snapCuenta.data!.data() as Map<String, dynamic>;
                String texto;
                if (data['tipo'] == 'dinero_en_mano') {
                  texto = 'Dinero en mano (eliminada)';
                } else {
                  texto = '${data['banco']} - ${data['numeroCuenta']} (eliminada)';
                }
                items.add(DropdownMenuItem(
                  value: _cuentaAsociada, 
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ));
              } else {
                // La cuenta no existe, cambiar a 'ninguna' automáticamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _cuentaAsociada = 'ninguna';
                    });
                  }
                });
                _cuentaAsociada = 'ninguna';
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuenta Asociada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _cuentaAsociada,
                    items: items,
                    onChanged: (v) => setState(() => _cuentaAsociada = v!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              );
            },
          );
        }
        // Validar que el valor actual exista en la lista
        if (!items.any((item) => item.value == _cuentaAsociada)) {
          _cuentaAsociada = 'ninguna';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuenta Asociada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _cuentaAsociada,
              items: items,
              onChanged: (v) => setState(() => _cuentaAsociada = v!),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String? error;
        if (widget.esEdicion && widget.gastoExistente != null) {
          // Para edición, usar el nuevo sistema de frecuencias
          error = await _gastosServicio.actualizarGastoConFrecuencia(
            gastoId: widget.gastoExistente!['id'],
            monto: monto,
            fecha: _fechaSeleccionada,
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
            metodoPago: _metodoPagoSeleccionado,
            frecuenciaActual: _frecuenciaOriginal,
            nuevaFrecuencia: _frecuencia,
            cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          );
        } else {
          // Para creación, verificar si tiene frecuencia
          if (_frecuencia != TipoFrecuencia.ninguna) {
            error = await _gastosServicio.crearGastoConFrecuencia(
              monto: monto,
              fechaInicial: _fechaSeleccionada,
              descripcion: _descripcionController.text.trim(),
              categoria: _categoriaSeleccionada,
              metodoPago: _metodoPagoSeleccionado,
              frecuencia: _frecuencia,
              cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
            );
          } else {
            // Crear gasto normal sin frecuencia usando el método original
            error = await _gastosServicio.crearGasto(
              descripcion: _descripcionController.text.trim(),
              monto: monto,
              fecha: _fechaSeleccionada,
              categoria: _categoriaSeleccionada,
              metodoPago: _metodoPagoSeleccionado,
              cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
              notas: '',
              recordatorio: _tieneRecordatorio ? _fechaRecordatorio : null,
            );
          }
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
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}