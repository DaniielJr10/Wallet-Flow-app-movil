/// FORMULARIO DE GESTIÓN DE AHORROS
/// BottomSheet para Crear y Editar ahorros siguiendo el mismo diseño que ingresos/gastos.
/// Gestiona validaciones de campos, selectores de fecha y comunicación con los servicios de Firebase.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import 'utils_ahorros.dart';

class FormularioAhorroMejorado extends StatefulWidget {
  final bool esEdicion;
  final String? ahorroId;
  final Map<String, dynamic>? ahorroExistente;
  final VoidCallback onGuardar;

  const FormularioAhorroMejorado({
    super.key,
    this.esEdicion = false,
    this.ahorroId,
    this.ahorroExistente,
    required this.onGuardar,
  });

  @override
  State<FormularioAhorroMejorado> createState() => _FormularioAhorroMejoradoState();
}

class _FormularioAhorroMejoradoState extends State<FormularioAhorroMejorado> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoInicialController = TextEditingController();
  final _agregarDineroController = TextEditingController();
  final _montoObjetivoController = TextEditingController();
  final AhorrosServicio _ahorrosServicio = AhorrosServicio();

  DateTime _fechaObjetivo = DateTime.now().add(const Duration(days: 365));
  String _categoriaSeleccionada = 'vacaciones';
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion && widget.ahorroExistente != null) {
      final ahorro = widget.ahorroExistente!;
      _nombreController.text = ahorro['nombre'] ?? '';
      _montoInicialController.text = FormatoNumeros.formatearParaMostrar(ahorro['montoInicial'] ?? 0.0);
      _montoObjetivoController.text = FormatoNumeros.formatearParaMostrar(ahorro['montoObjetivo'] ?? 0.0);
      _fechaObjetivo = ahorro['fechaObjetivo'] is DateTime
          ? ahorro['fechaObjetivo']
          : (ahorro['fechaObjetivo'] is Timestamp 
              ? (ahorro['fechaObjetivo'] as Timestamp).toDate() 
              : DateTime.now().add(const Duration(days: 365)));
      _categoriaSeleccionada = ahorro['categoria'] ?? 'vacaciones';
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
                colors: [
                  UtilsAhorros.colorPrincipal,
                  Color(0xFF9F7AFA), // Color secundario más claro
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esEdicion ? 'Editar Ahorro' : 'Nuevo Ahorro',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
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
                    _buildCampoNombre(),
                    const SizedBox(height: 20),
                    if (!widget.esEdicion) _buildCampoMontoInicial(),
                    if (!widget.esEdicion) const SizedBox(height: 20),
                    if (widget.esEdicion) _buildCampoAgregarDinero(),
                    if (widget.esEdicion) const SizedBox(height: 20),
                    _buildCampoMontoObjetivo(),
                    const SizedBox(height: 20),
                    _buildSelectorFecha(),
                    const SizedBox(height: 20),
                    _buildSelectorCategoria(),
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

  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del ahorro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nombreController,
          validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el nombre del ahorro' : null,
          decoration: _getInputDecoration('Ej: Vacaciones familiares'),
        ),
      ],
    );
  }

  Widget _buildCampoMontoInicial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monto inicial',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoInicialController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FormateadorNumeros()],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingresa el monto inicial';
            final monto = FormatoNumeros.convertirANumero(value);
            if (monto == null || monto < 0) return 'Monto inválido';
            return null;
          },
          decoration: _getInputDecoration('\$0'),
        ),
      ],
    );
  }

  Widget _buildCampoAgregarDinero() {
    final montoActual = widget.ahorroExistente?['montoActual'] ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agregar dinero al ahorro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Monto actual: ${FormatoNumeros.formatearParaMostrar(montoActual)}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _agregarDineroController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FormateadorNumeros()],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final monto = FormatoNumeros.convertirANumero(value);
              if (monto == null || monto <= 0) return 'Monto inválido';
            }
            return null;
          },
          decoration: _getInputDecoration('Opcional - Dinero a agregar').copyWith(
            prefixIcon: const Icon(Icons.add_circle_outline, color: UtilsAhorros.colorPrincipal),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoMontoObjetivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monto objetivo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoObjetivoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FormateadorNumeros()],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingresa el monto objetivo';
            final monto = FormatoNumeros.convertirANumero(value);
            if (monto == null || monto <= 0) return 'Monto inválido';
            return null;
          },
          decoration: _getInputDecoration('\$1.000.000'),
        ),
      ],
    );
  }

  Widget _buildSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha objetivo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _mostrarSelectorFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: UtilsAhorros.colorPrincipal, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_fechaObjetivo.day}/${_fechaObjetivo.month}/${_fechaObjetivo.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
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
        const Text(
          'Categoría',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              items: UtilsAhorros.categorias.map((categoria) => DropdownMenuItem<String>(
                value: categoria['valor'] as String,
                child: Row(
                  children: [
                    Icon(categoria['icono'], color: UtilsAhorros.colorPrincipal, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      categoria['nombre'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _categoriaSeleccionada = valor);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: _cargando ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _cargando ? null : _guardarAhorro,
            style: ElevatedButton.styleFrom(
              backgroundColor: UtilsAhorros.colorPrincipal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    widget.esEdicion ? 'Actualizar Ahorro' : 'Guardar Ahorro',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarSelectorFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaObjetivo,
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
    if (fecha != null) {
      setState(() => _fechaObjetivo = fecha);
    }
  }

  Future<void> _guardarAhorro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final nombre = _nombreController.text.trim();
      final montoObjetivo = FormatoNumeros.convertirANumero(_montoObjetivoController.text) ?? 0.0;
      String? error;

      if (widget.esEdicion && widget.ahorroId != null) {
        // Actualizar datos básicos
        error = await _ahorrosServicio.actualizarMetaAhorro(
          metaId: widget.ahorroId!,
          nombre: nombre,
          montoObjetivo: montoObjetivo,
          fechaObjetivo: _fechaObjetivo,
          categoria: _categoriaSeleccionada,
        );

        // Agregar dinero si se especificó
        final dineroAgregar = FormatoNumeros.convertirANumero(_agregarDineroController.text) ?? 0.0;
        if (error == null && dineroAgregar > 0) {
          error = await _ahorrosServicio.agregarMontoMeta(
            metaId: widget.ahorroId!,
            montoAgregar: dineroAgregar,
          );
        }
      } else {
        // Crear nuevo ahorro
        final montoInicial = FormatoNumeros.convertirANumero(_montoInicialController.text) ?? 0.0;
        error = await _ahorrosServicio.crearMetaAhorro(
          nombre: nombre,
          montoInicial: montoInicial,
          montoObjetivo: montoObjetivo,
          fechaObjetivo: _fechaObjetivo,
          categoria: _categoriaSeleccionada,
        );
      }

      if (mounted) {
        if (error == null) {
          Navigator.pop(context);
          widget.onGuardar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.esEdicion ? 'Ahorro actualizado correctamente' : 'Ahorro creado correctamente'),
              backgroundColor: UtilsAhorros.colorPrincipal,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: UtilsAhorros.colorPrincipal),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: UtilsAhorros.colorPrincipal),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: UtilsAhorros.colorPrincipal, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _montoInicialController.dispose();
    _agregarDineroController.dispose();
    _montoObjetivoController.dispose();
    super.dispose();
  }
}
