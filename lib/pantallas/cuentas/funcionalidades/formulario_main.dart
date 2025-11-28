/// LÓGICA DEL FORMULARIO
/// Maneja la creación y edición de cuentas. Controla:
/// - Los controladores de texto (TextEditingController).
/// - La validación del formulario (FormKey).
/// - La llamada al servicio de Firebase para guardar/actualizar.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../firebase/servicios/CuentaService/cuentas_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'formulario_inputs.dart';

class FormularioCuenta extends StatefulWidget {
  final VoidCallback onCuentaAgregada;
  final String? cuentaId;
  final Map<String, dynamic>? cuentaExistente;

  const FormularioCuenta({
    super.key,
    required this.onCuentaAgregada,
    this.cuentaId,
    this.cuentaExistente,
  });

  @override
  State<FormularioCuenta> createState() => _FormularioCuentaState();
}

class _FormularioCuentaState extends State<FormularioCuenta> {
  final _formKey = GlobalKey<FormState>();
  final _bancoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _saldoController = TextEditingController();
  
  String _tipoSeleccionado = 'ahorros';
  bool _cargando = false;

  final List<Map<String, dynamic>> _tiposCuenta = [
    {
      'valor': 'ahorros',
      'nombre': 'Cuenta de Ahorros',
      'icono': Icons.savings_outlined,
      'color': const Color(0xFF007bff),
    },
    {
      'valor': 'corriente',
      'nombre': 'Cuenta Corriente',
      'icono': Icons.account_balance_outlined,
      'color': const Color(0xFF007bff),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cuentaExistente != null) {
      _cargarDatosCuenta();
    }
  }

  void _cargarDatosCuenta() {
    final cuenta = widget.cuentaExistente!;
    _bancoController.text = cuenta['banco'] ?? '';
    _numeroController.text = cuenta['numeroCuenta'] ?? '';
    _saldoController.text = FormatoNumeros.formatearNumero(cuenta['saldo'] ?? 0.0);
    _tipoSeleccionado = cuenta['tipo'] ?? 'ahorros';
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.cuentaExistente != null;
    final maxHeight = MediaQuery.of(context).size.height * 0.77;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = maxHeight - keyboardHeight;
    
    return Container(
      height: keyboardHeight > 0 ? availableHeight : maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF007bff),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        esEdicion ? 'Editar Cuenta' : 'Agregar Cuenta',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
          
          // Formulario limpio
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de cuenta
                    const Row(
                      children: [
                        Icon(Icons.category_outlined, color: Color(0xFF007bff), size: 20),
                        SizedBox(width: 8),
                        Text('Tipo de cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    SelectorTipoCuenta(
                      tiposCuenta: _tiposCuenta,
                      tipoSeleccionado: _tipoSeleccionado,
                      onSeleccionado: (valor) {
                        setState(() {
                          _tipoSeleccionado = valor;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    InputFormularioCuenta(
                      controller: _bancoController,
                      label: 'Banco',
                      hint: 'Ej: Banco Nacional',
                      icon: Icons.account_balance,
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'El banco es requerido' : null,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    InputFormularioCuenta(
                      controller: _numeroController,
                      label: 'Número de cuenta',
                      hint: 'Número completo de la cuenta',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'El número de cuenta es requerido' : null,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    InputFormularioCuenta(
                      controller: _saldoController,
                      label: 'Saldo inicial',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [FormateadorNumeros()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'El saldo es requerido';
                        if (FormatoNumeros.convertirANumero(value) == null) return 'Ingresa un saldo válido';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Botón guardar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007bff).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _cargando ? null : _guardarCuenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007bff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          esEdicion ? Icons.update : Icons.save,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          esEdicion ? 'Actualizar Cuenta' : 'Crear Cuenta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  Future<void> _guardarCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
    });

    try {
      final cuentasServicio = CuentasServicio();
      String? error;
      
      if (widget.cuentaId != null) {
        error = await cuentasServicio.actualizarCuenta(
          cuentaId: widget.cuentaId!,
          banco: _bancoController.text.trim(),
          numeroCuenta: _numeroController.text.trim(),
          tipo: _tipoSeleccionado,
          saldo: FormatoNumeros.convertirANumero(_saldoController.text) ?? 0,
        );
      } else {
        error = await cuentasServicio.crearCuenta(
          banco: _bancoController.text.trim(),
          numeroCuenta: _numeroController.text.trim(),
          tipo: _tipoSeleccionado,
          saldo: FormatoNumeros.convertirANumero(_saldoController.text) ?? 0,
        );
      }

      if (mounted) {
        if (error == null) {
          Navigator.pop(context);
          widget.onCuentaAgregada();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.cuentaId != null 
                  ? 'Cuenta actualizada correctamente'
                  : 'Cuenta creada correctamente'
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bancoController.dispose();
    _numeroController.dispose();
    _saldoController.dispose();
    super.dispose();
  }
}