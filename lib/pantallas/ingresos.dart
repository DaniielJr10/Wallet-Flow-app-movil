import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilidades/formato_numeros.dart';
import '../firebase/servicios/ingresos_servicio.dart';
import '../firebase/servicios/cuentas_servicio.dart';

class PantallaIngresos extends StatefulWidget {
  const PantallaIngresos({super.key});

  @override
  State<PantallaIngresos> createState() => _PantallaIngresosState();
}

class _PantallaIngresosState extends State<PantallaIngresos> with TickerProviderStateMixin {
  // === SERVICIOS ===
  final IngresosServicio _ingresosServicio = IngresosServicio();
  final CuentasServicio _cuentasServicio = CuentasServicio();
  
  // Filtros adicionales
  String _modoBusqueda = 'categoría'; // 'categoría' o 'mes'

  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime? _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'alimentación';
  String _metodoPagoSeleccionado = 'transferencia';
  String _cuentaAsociada = 'ninguna';

  List<Map<String, dynamic>> _ingresos = [];
  String _busqueda = '';
  /// Filtra los ingresos según el texto de búsqueda y los filtros seleccionados
  List<Map<String, dynamic>> get _ingresosFiltrados {
    return _ingresos.where((ingreso) {
      bool coincideBusqueda = true;
      if (_busqueda.isNotEmpty) {
        if (_modoBusqueda == 'categoría') {
          coincideBusqueda = ingreso['categoria'].toString().toLowerCase().contains(_busqueda.toLowerCase());
        } else if (_modoBusqueda == 'mes') {
          // Buscar por mes escrito (ej: "noviembre")
          final meses = [
            'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
            'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
          ];
          final fecha = ingreso['fecha'] as DateTime;
          final mesIngreso = meses[fecha.month - 1];
          coincideBusqueda = mesIngreso.contains(_busqueda.toLowerCase());
        }
      }
      return coincideBusqueda;
    }).toList();
  }

  /// Muestra el modal de filtros
  void _mostrarModalFiltros() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.filter_alt_rounded, color: Color(0xFF2ecc71), size: 20),
                  const SizedBox(width: 8),
                  const Text('Buscar por:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _modoBusqueda = 'categoría');
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _modoBusqueda == 'categoría' ? const Color(0xFF2ecc71) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Categoría',
                            style: TextStyle(
                              color: _modoBusqueda == 'categoría' ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _modoBusqueda = 'mes');
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _modoBusqueda == 'mes' ? const Color(0xFF2ecc71) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Mes',
                            style: TextStyle(
                              color: _modoBusqueda == 'mes' ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Escribe el nombre de la categoría o el mes (ej: "noviembre") en la barra de búsqueda.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  final List<String> _categorias = [
    'alimentación',
    'transporte',
    'entretenimiento',
    'salud',
    'educación',
    'servicios',
    'compras',
    'viajes',
    'otro'
  ];

  final List<String> _metodosPago = [
    'transferencia',
    'efectivo',
    'cheque',
    'tarjeta'
  ];

  /// Inicializa el estado del widget y configura las animaciones
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _cargarIngresosDePrueba();
  }

  /// Libera los recursos utilizados por los controladores y animaciones
  @override
  void dispose() {
    _animationController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Carga datos de prueba para mostrar ejemplos de ingresos
  void _cargarIngresosDePrueba() {
    setState(() {
      _ingresos = [
        {
          'id': '1',
          'monto': 2500.00,
          'fecha': DateTime.now().subtract(const Duration(days: 2)),
          'descripcion': 'Salario mensual',
          'categoria': 'trabajo',
          'metodoPago': 'transferencia',
        },
        {
          'id': '2',
          'monto': 500.00,
          'fecha': DateTime.now().subtract(const Duration(days: 5)),
          'descripcion': 'Proyecto freelance',
          'categoria': 'freelance',
          'metodoPago': 'transferencia',
        },
      ];
    });
  }

  /// Muestra el modal con el formulario para registrar un nuevo ingreso
  void _mostrarFormularioIngreso() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFormularioModal(),
    );
  }

  /// Construye el modal que contiene el formulario de nuevo ingreso
  Widget _buildFormularioModal() {
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
                colors: [
                  Color(0xFF2ecc71),
                  Color(0xFF27ae60),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nuevo Ingreso',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    _buildCampoMonto(),
                    const SizedBox(height: 20),
                    _buildCampoDescripcion(),
                    const SizedBox(height: 20),
                    _buildSelectorFecha(),
                    const SizedBox(height: 20),
                    _buildSelectorCategoria(),
                    const SizedBox(height: 20),
                    _buildSelectorMetodoPago(),
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

  /// Construye el campo de entrada para el monto del ingreso
  Widget _buildCampoMonto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FormateadorNumeros(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el monto';
            }
            final monto = FormatoNumeros.convertirANumero(value);
            if (monto == null || monto <= 0) {
              return 'Ingresa un monto válido mayor a 0';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: '45.789',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2ecc71), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el campo de entrada para la descripción del ingreso
  Widget _buildCampoDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una descripción';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ej: Salario mensual, proyecto freelance...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2ecc71), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el selector de fecha para el ingreso
  Widget _buildSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF2ecc71),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _fechaSeleccionada != null
                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                      : 'Seleccionar fecha',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar la categoría del ingreso
  Widget _buildSelectorCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(
                    categoria.substring(0, 1).toUpperCase() + categoria.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar el método de pago
  Widget _buildSelectorMetodoPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _metodoPagoSeleccionado,
              isExpanded: true,
              items: _metodosPago.map((metodo) {
                return DropdownMenuItem(
                  value: metodo,
                  child: Text(
                    metodo.substring(0, 1).toUpperCase() + metodo.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _metodoPagoSeleccionado = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los botones de acción del formulario (Cancelar y Guardar)
  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarFormulario();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarIngreso,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2ecc71),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la lista de ingresos registrados o muestra estado vacío
  Widget _buildListaIngresos() {
    final lista = _ingresosFiltrados;
    if (lista.isEmpty) {
      return _buildEstadoVacio();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final ingreso = lista[index];
        // Buscar el índice real en la lista original para eliminar correctamente
        final realIndex = _ingresos.indexOf(ingreso);
        return _buildTarjetaIngreso(ingreso, realIndex);
      },
    );
  }

  /// Construye una tarjeta individual para mostrar un ingreso
  Widget _buildTarjetaIngreso(Map<String, dynamic> ingreso, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconoCategoria(ingreso['categoria']),
            color: Colors.green.shade600,
            size: 24,
          ),
        ),
        title: Text(
          ingreso['descripcion'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${ingreso['categoria'].toString().substring(0, 1).toUpperCase()}${ingreso['categoria'].toString().substring(1)} • ${ingreso['metodoPago'].toString().substring(0, 1).toUpperCase()}${ingreso['metodoPago'].toString().substring(1)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${ingreso['fecha'].day}/${ingreso['fecha'].month}/${ingreso['fecha'].year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2ecc71),
              ),
            ),
              // Icono de borrar eliminado
          ],
        ),
      ),
    );
  }

  /// Muestra un estado vacío cuando no hay ingresos registrados
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.attach_money_rounded,
              size: 64,
              color: Colors.green.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay ingresos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer ingreso',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Construye la tarjeta de resumen con el total de ingresos
  Widget _buildResumenIngresos() {
    final totalIngresos = _ingresos.fold<double>(
      0.0,
      (sum, ingreso) => sum + ingreso['monto'],
    );

    final ingresosPorCategoria = <String, double>{};
    for (final ingreso in _ingresos) {
      final categoria = ingreso['categoria'] as String;
      ingresosPorCategoria[categoria] = 
          (ingresosPorCategoria[categoria] ?? 0.0) + ingreso['monto'];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2ecc71),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2ecc71).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de Ingresos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_ingresos.length} registros',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${totalIngresos.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualizado hace unos minutos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna el ícono correspondiente según la categoría del ingreso
  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'trabajo':
        return Icons.work_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'venta':
        return Icons.sell_rounded;
      case 'inversión':
        return Icons.trending_up_rounded;
      case 'regalo':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  /// Abre el selector de fecha para elegir cuándo se realizó el ingreso
  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  /// Valida y guarda un nuevo ingreso
  Future<void> _guardarIngreso() async {
    if (_formKey.currentState!.validate()) {
      final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0;
      
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Registrar el ingreso usando el servicio
        final error = await _ingresosServicio.registrarIngreso(
          monto: monto,
          fecha: _fechaSeleccionada ?? DateTime.now(),
          descripcion: _descripcionController.text.trim(),
          categoria: _categoriaSeleccionada,
          metodoPago: _metodoPagoSeleccionado,
          cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
        );

        if (mounted) {
          // Cerrar indicador de carga
          Navigator.pop(context);
          
          if (error != null) {
            // Mostrar error
            _mostrarError(error);
          } else {
            // Éxito
            Navigator.pop(context); // Cerrar formulario
            _limpiarFormulario();
            _mostrarMensajeExito();
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Cerrar indicador de carga
          _mostrarError('Error inesperado: ${e.toString()}');
        }
      }
    }
  }

  /// Limpia todos los campos del formulario y restablece valores por defecto
  void _limpiarFormulario() {
    _montoController.clear();
    _descripcionController.clear();
    setState(() {
      _fechaSeleccionada = DateTime.now();
      _categoriaSeleccionada = 'trabajo';
      _metodoPagoSeleccionado = 'transferencia';
      _cuentaAsociada = 'ninguna';
    });
  }

  /// Muestra un diálogo de confirmación para eliminar un ingreso
  void _eliminarIngreso(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar Ingreso'),
        content: const Text('¿Estás seguro de que deseas eliminar este ingreso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ingresos.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ingreso eliminado correctamente'),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de éxito cuando se registra un ingreso correctamente
  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ingreso registrado correctamente'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Muestra un mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null,
        toolbarHeight: 0, // Oculta la barra superior
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header bonito y centrado
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        color: Color(0xFF27ae60),
                        size: 32,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'INGRESOS',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900, // Aún más gruesa
                          color: Color(0xFF27ae60),
                          letterSpacing: 2.2,
                          fontFamily: 'Montserrat',
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestiona y controla todos tus ingresos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              _buildResumenIngresos(),
              const SizedBox(height: 24),
              // Campo de búsqueda con botón de filtros
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _modoBusqueda == 'categoría' ? 'Buscar por categoría...' : 'Buscar por mes (ej: noviembre)...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF2ecc71), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF27ae60), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _busqueda.isNotEmpty
                              ? IconButton(
                                  key: const ValueKey('clear'),
                                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                                  onPressed: () {
                                    setState(() => _busqueda = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _busqueda = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(Icons.filter_alt_rounded, color: Color(0xFF2ecc71), key: ValueKey(_modoBusqueda)),
                      ),
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF2ecc71), width: 0.7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded, color: Color(0xFF2ecc71), size: 18),
                              const SizedBox(width: 8),
                              Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2ecc71))),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem(
                          value: 'categoría',
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.category_rounded, color: _modoBusqueda == 'categoría' ? Color(0xFF2ecc71) : Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Text('Por categoría', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                              if (_modoBusqueda == 'categoría') ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check_circle_rounded, color: Color(0xFF2ecc71), size: 18),
                              ]
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'mes',
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: _modoBusqueda == 'mes' ? Color(0xFF2ecc71) : Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Text('Por mes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                              if (_modoBusqueda == 'mes') ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check_circle_rounded, color: Color(0xFF2ecc71), size: 18),
                              ]
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _modoBusqueda = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historial de Ingresos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioIngreso,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nuevo Ingreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ecc71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildListaIngresos(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // FloatingActionButton eliminado según solicitud
    );
  }
}
