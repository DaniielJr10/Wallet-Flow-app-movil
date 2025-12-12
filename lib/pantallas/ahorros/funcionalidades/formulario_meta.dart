// 8. Formulario para crear o editar una meta de ahorro
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/servicios/AhorroService/ahorros_servicio.dart';
import '../../../utilidades/formato_numeros.dart';
import '../../../pantallas/configuracion/funcionalidades/notificaciones/preferencias_notificaciones.dart';
import 'notificaciones/servicio_notificaciones_ahorros.dart';
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
  final TextEditingController _montoActualController = TextEditingController();
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
      _montoActualController.text = FormatoNumeros.formatearParaMostrar(widget.meta!['montoActual'] ?? 0.0);
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
                        prefixIcon: Icon(Icons.savings, color: UtilsAhorros.colorPrincipal),
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
                        prefixIcon: Icon(Icons.monetization_on, color: UtilsAhorros.colorPrincipal),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo monto actual - solo visible en edición
                    if (widget.esEdicion) ...[
                      const Text('Monto actual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _montoActualController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FormateadorNumeros()],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa el monto actual';
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
                          prefixIcon: Icon(Icons.account_balance_wallet, color: UtilsAhorros.colorPrincipal),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
                        prefixIcon: Icon(Icons.flag, color: UtilsAhorros.colorPrincipal),
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
      final montoActual = widget.esEdicion ? FormatoNumeros.convertirANumero(_montoActualController.text) ?? 0.0 : montoInicial;
      final montoObjetivo = FormatoNumeros.convertirANumero(_montoObjetivoController.text) ?? 0.0;
      final fechaObjetivo = _fechaAhorro ?? DateTime.now();
      final nombreMeta = _nombreController.text.trim();
      String? error;

      if (widget.esEdicion && widget.metaId != null) {
        // Primero actualizamos los datos básicos
        error = await _ahorrosServicio.actualizarMetaAhorro(
          metaId: widget.metaId!,
          nombre: nombreMeta,
          montoObjetivo: montoObjetivo,
          fechaObjetivo: fechaObjetivo,
          categoria: _categoriaAhorro,
        );
        
        // Si la actualización básica fue exitosa, actualizar el monto actual
        if (error == null) {
          final montoActualOriginal = (widget.meta?['montoActual'] ?? 0.0).toDouble();
          final diferencia = montoActual - montoActualOriginal;
          
          // Solo hacer cambio si hay diferencia
          if (diferencia != 0) {
            error = await _ahorrosServicio.agregarMontoMeta(
              metaId: widget.metaId!,
              montoAgregar: diferencia,
            );
          }
          
          // Reprogramar notificaciones con los nuevos datos
          await _programarNotificacionesVencimiento(
            metaId: widget.metaId!,
            nombreMeta: nombreMeta,
            montoObjetivo: montoObjetivo,
            montoActual: montoActual,
            fechaLimite: fechaObjetivo,
          );
        }
      } else {
        // Crear nueva meta
        final resultado = await _ahorrosServicio.crearMetaAhorro(
          nombre: nombreMeta,
          montoInicial: montoInicial,
          montoObjetivo: montoObjetivo,
          fechaObjetivo: fechaObjetivo,
          categoria: _categoriaAhorro,
        );
        
        error = resultado['error'];
        final metaId = resultado['metaId'];
        
        // Si se creó exitosamente, programar notificaciones
        if (error == null && metaId != null) {
          await _programarNotificacionesVencimiento(
            metaId: metaId,
            nombreMeta: nombreMeta,
            montoObjetivo: montoObjetivo,
            montoActual: montoInicial,
            fechaLimite: fechaObjetivo,
          );
        }
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
              backgroundColor: UtilsAhorros.colorPrincipal,
            ),
          );
        }
      }
    }
  }

  /// Programa las notificaciones de vencimiento para una meta
  Future<void> _programarNotificacionesVencimiento({
    required String metaId,
    required String nombreMeta,
    required double montoObjetivo,
    required double montoActual,
    required DateTime fechaLimite,
  }) async {
    try {
      // Verificar si las notificaciones de ahorros están activas
      final notificacionesActivas = await PreferenciasNotificaciones.obtenerPreferencia('ahorros');
      
      if (!notificacionesActivas) {
        print('🔇 Notificaciones de ahorros desactivadas - No se programan alertas');
        return;
      }
      
      // Generar un ID numérico para la meta (usando hashCode del metaId)
      final metaIdNumerico = metaId.hashCode.abs() % 1000000;
      
      // Programar alertas de vencimiento (7, 3 y 1 días antes)
      await ServicioNotificacionesAhorros.instance.programarAlertaMetaProximaVencer(
        metaId: metaIdNumerico,
        nombreMeta: nombreMeta,
        montoObjetivo: montoObjetivo,
        montoActual: montoActual,
        fechaLimite: fechaLimite,
      );
      
      print('✅ Notificaciones de vencimiento programadas para: $nombreMeta');
    } catch (e) {
      print('❌ Error programando notificaciones: $e');
    }
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _montoInicialController.dispose();
    _montoActualController.dispose();
    _montoObjetivoController.dispose();
    super.dispose();
  }
}