import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/servicios/cuentas_servicio.dart';
import '../firebase/servicios/gastos_servicio.dart';
import '../utilidades/formato_numeros.dart';

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos> with TickerProviderStateMixin {
  final CuentasServicio _cuentasServicio = CuentasServicio();
  final GastosServicio _gastosServicio = GastosServicio();
  // Modo de búsqueda: 'categoría' o 'mes'
  String _modoBusqueda = 'categoría';

  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  // ...eliminado controlador de nota...
  final _busquedaController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime? _fechaSeleccionada = DateTime.now();
  String _categoriaSeleccionada = 'alimentación';
  String _metodoPagoSeleccionado = 'efectivo';
  String _cuentaAsociada = 'ninguna';
  bool _esRecurrente = false;
  String _frecuenciaRecurrente = 'mensual';
  String _textoBusqueda = '';

  List<Map<String, dynamic>> _gastos = [];

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
    'efectivo',
    'transferencia',
  ];

  // Eliminado _cuentas, ahora se obtiene de Firestore

  // ...eliminado lista de frecuencias...

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
    _inicializarGastos();
  }

  /// Libera los recursos utilizados por los controladores y animaciones
  @override
  void dispose() {
    _animationController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    // ...eliminado dispose de notaController...
    _busquedaController.dispose();
    super.dispose();
  }

  /// Inicializa la lista de gastos vacía para usar datos reales de Firebase
  void _inicializarGastos() {
    setState(() {
      _gastos = [];
    });
  }

  /// Filtra los gastos según el modo de búsqueda (categoría o mes)
  void _filtrarGastos(String textoBusqueda) {
    setState(() {
      _textoBusqueda = textoBusqueda;
      // El filtrado ahora se hace en el StreamBuilder
    });
  }

  /// Muestra el modal con el formulario para registrar un nuevo gasto
  void _mostrarFormularioGasto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFormularioModal(),
    );
  }

  /// Construye el modal que contiene el formulario de nuevo gasto
  Widget _buildFormularioModal() {
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
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade700,
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
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nuevo Gasto',
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
                    const SizedBox(height: 20),
                    _buildSelectorCuentaAsociada(),
                    const SizedBox(height: 20),
                    // ...eliminado campo de nota opcional...
                    const SizedBox(height: 20),
                    // ...eliminado gasto recurrente...
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

  /// Construye el campo de entrada para el monto del gasto
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
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el campo de entrada para la descripción del gasto
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
            hintText: 'Ej: Supermercado, gasolina, cena...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// Construye el selector de fecha para el gasto
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
                  color: Colors.red.shade600,
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

  /// Construye el dropdown para seleccionar la categoría del gasto
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
        DropdownButtonFormField<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: _categorias.map((categoria) {
            return DropdownMenuItem(
              value: categoria,
              child: Row(
                children: [
                  Icon(
                    _getIconoCategoria(categoria),
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    categoria.substring(0, 1).toUpperCase() + categoria.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoriaSeleccionada = value!;
            });
          },
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
        DropdownButtonFormField<String>(
          value: _metodoPagoSeleccionado,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
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
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _metodoPagoSeleccionado) {
              setState(() {
                _metodoPagoSeleccionado = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  /// Construye el dropdown para seleccionar la cuenta asociada
  Widget _buildSelectorCuentaAsociada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuenta Asociada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: _cuentasServicio.obtenerCuentas(),
          builder: (context, snapshot) {
            List<DropdownMenuItem<String>> items = [
              const DropdownMenuItem(
                value: 'ninguna',
                child: Text('Ninguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ];
            if (snapshot.connectionState == ConnectionState.waiting) {
              items = [
                const DropdownMenuItem(
                  value: 'ninguna',
                  child: Text('Cargando...', style: TextStyle(fontSize: 16)),
                ),
              ];
            } else if (snapshot.hasData && snapshot.data != null) {
              for (var doc in snapshot.data!.docs) {
                try {
                  final cuenta = doc.data() as Map<String, dynamic>?;
                  if (cuenta != null) {
                    final banco = cuenta['banco']?.toString() ?? 'Banco';
                    final numero = cuenta['numeroCuenta']?.toString() ?? '****';
                    final cuentaId = doc.id;
                    items.add(DropdownMenuItem(
                      value: cuentaId,
                      child: Text(
                        '$banco - $numero',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ));
                  }
                } catch (e) {
                  continue;
                }
              }
            }
            final validValues = items.map((item) => item.value).toSet();
            if (!validValues.contains(_cuentaAsociada)) {
              _cuentaAsociada = 'ninguna';
            }
            return DropdownButtonFormField<String>(
              value: _cuentaAsociada,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: items,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != _cuentaAsociada) {
                  setState(() {
                    _cuentaAsociada = newValue;
                  });
                }
              },
            );
          },
        ),
      ],
    );
  }

  /// Construye el campo opcional para notas adicionales
  // ...eliminado campo de nota opcional...

  /// Construye el switch para marcar el gasto como recurrente
  // ...eliminado switch de gasto recurrente...

  /// Construye el selector de frecuencia para gastos recurrentes
  // ...eliminado selector de frecuencia de gasto recurrente...

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
            onPressed: _guardarGasto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
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

  /// Construye una barra de búsqueda moderna y profesional
  Widget _buildBarraBusqueda() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _busquedaController,
              onChanged: _filtrarGastos,
              decoration: InputDecoration(
                hintText: _modoBusqueda == 'categoría'
                    ? 'Buscar por categoría...'
                    : 'Buscar por mes (ej: noviembre)...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                suffixIcon: _textoBusqueda.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _busquedaController.clear();
                          _filtrarGastos('');
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.red.shade300,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
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
              child: Icon(Icons.filter_alt_rounded, color: Color(0xFFe53935), key: ValueKey(_modoBusqueda)),
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFe53935), width: 0.7),
            ),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFFe53935), size: 18),
                    const SizedBox(width: 8),
                    Text('Modo de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFe53935))),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'categoría',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.category_rounded, color: _modoBusqueda == 'categoría' ? Color(0xFFe53935) : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text('Por categoría', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    if (_modoBusqueda == 'categoría') ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: Color(0xFFe53935), size: 18),
                    ]
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mes',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: _modoBusqueda == 'mes' ? Color(0xFFe53935) : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text('Por mes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    if (_modoBusqueda == 'mes') ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: Color(0xFFe53935), size: 18),
                    ]
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              setState(() {
                _modoBusqueda = value;
                _filtrarGastos(_textoBusqueda);
              });
            },
          ),
        ),
      ],
    );
  }

  /// Construye la lista de gastos registrados usando StreamBuilder con Firebase
  Widget _buildListaGastos() {
    return StreamBuilder<QuerySnapshot>(
      stream: _gastosServicio.obtenerGastos(),
      builder: (context, snapshot) {
        // Mostrar indicador de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
          );
        }
        
        // Manejar errores con información detallada
        if (snapshot.hasError) {
          print('Error en StreamBuilder: ${snapshot.error}');
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar gastos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                  ),
                  child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        
        // Verificar si no hay datos
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEstadoVacio();
        }
        
        // Convertir documentos de Firebase a lista local y filtrar por activo
        final gastosFirebase = <Map<String, dynamic>>[];
        try {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              // Filtrar solo gastos activos
              final activo = data['activo'] as bool? ?? true;
              if (!activo) continue; // Saltar gastos inactivos
              
              data['id'] = doc.id;
              
              // Convertir Timestamp a DateTime si es necesario
              if (data['fecha'] is Timestamp) {
                data['fecha'] = (data['fecha'] as Timestamp).toDate();
              }
              
              // Asegurar que los campos requeridos existan
              data['descripcion'] = data['descripcion'] ?? 'Sin descripción';
              data['monto'] = (data['monto'] as num?)?.toDouble() ?? 0.0;
              data['categoria'] = data['categoria'] ?? 'otro';
              data['metodoPago'] = data['metodoPago'] ?? 'efectivo';
              data['fecha'] = data['fecha'] ?? DateTime.now();
              
              gastosFirebase.add(data);
            }
          }
        } catch (e) {
          print('Error procesando documentos: $e');
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade400,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error procesando datos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        // Actualizar lista local
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _gastos = gastosFirebase;
            });
          }
        });
        
        // Aplicar filtros de búsqueda
        List<Map<String, dynamic>> gastosAMostrar = gastosFirebase;
        if (_textoBusqueda.isNotEmpty) {
          gastosAMostrar = gastosFirebase.where((gasto) {
            final descripcion = (gasto['descripcion'] ?? '').toString().toLowerCase();
            final categoria = (gasto['categoria'] ?? '').toString().toLowerCase();
            final busqueda = _textoBusqueda.toLowerCase();
            
            return descripcion.contains(busqueda) || categoria.contains(busqueda);
          }).toList();
        }
        
        // Mostrar estado sin resultados de búsqueda
        if (gastosAMostrar.isEmpty && _textoBusqueda.isNotEmpty) {
          return _buildEstadoSinResultados();
        }
        
        // Mostrar estado vacío cuando no hay gastos
        if (gastosFirebase.isEmpty) {
          return _buildEstadoVacio();
        }
        
        // Mostrar lista de gastos
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gastosAMostrar.length,
          itemBuilder: (context, index) {
            final gasto = gastosAMostrar[index];
            return _buildTarjetaGastoSinCategoria(gasto, index);
          },
        );
      },
    );
  }

  /// Muestra un estado cuando no se encuentran resultados de búsqueda
  Widget _buildEstadoSinResultados() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron gastos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
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

  /// Muestra un modal con los detalles completos del gasto
  void _mostrarDetalleGasto(Map<String, dynamic> gasto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Detalles del gasto',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(_getIconoCategoria(gasto['categoria']), color: Colors.red.shade600, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gasto['descripcion'] ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detalleItem('Monto', '-${FormatoNumeros.formatearParaMostrar(gasto['monto'])}', color: Colors.red.shade600, fontSize: 20),
              _detalleItem('Fecha', gasto['fecha'] != null ? '${gasto['fecha'].day}/${gasto['fecha'].month}/${gasto['fecha'].year}' : ''),
              _detalleItem('Categoría', gasto['categoria'] ?? ''),
              _detalleItem('Método de pago', gasto['metodoPago'] ?? ''),
              _detalleItem('Cuenta asociada', gasto['cuentaAsociada'] ?? 'Ninguna'),
              if (gasto['nota'] != null && gasto['nota'].isNotEmpty)
                _detalleItem('Nota', gasto['nota'], italic: true),
              if (gasto['esRecurrente'] == true)
                _detalleItem('Recurrente', gasto['frecuencia'] != null ? 'Frecuencia: ${gasto['frecuencia']}' : 'Sí', color: Colors.orange),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarFormularioEdicionGasto(gasto);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _eliminarGasto(gasto['id']);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Muestra el formulario de edición de gasto con los datos cargados
  void _mostrarFormularioEdicionGasto(Map<String, dynamic> gasto) {
    // Cargar los datos en los controladores y variables
    _montoController.text = gasto['monto'].toString();
    _descripcionController.text = gasto['descripcion'] ?? '';
    _fechaSeleccionada = gasto['fecha'] ?? DateTime.now();
    _categoriaSeleccionada = gasto['categoria'] ?? 'alimentación';
    _metodoPagoSeleccionado = gasto['metodoPago'] ?? 'efectivo';
    _cuentaAsociada = gasto['cuentaAsociada'] ?? 'ninguna';
    _esRecurrente = gasto['esRecurrente'] ?? false;
    _frecuenciaRecurrente = gasto['frecuencia'] ?? 'mensual';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFormularioModalEdicion(gasto['id']),
    );
  }

  /// Construye el formulario de edición de gasto
  Widget _buildFormularioModalEdicion(String gastoId) {
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
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade700,
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
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Editar Gasto',
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
                    const SizedBox(height: 20),
                    _buildSelectorCuentaAsociada(),
                    const SizedBox(height: 20),
                    // ...eliminado campo de nota opcional...
                    const SizedBox(height: 20),
                    // ...eliminado gasto recurrente...
                    const SizedBox(height: 32),
                    Row(
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
                            onPressed: () => _actualizarGasto(gastoId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  /// Actualiza el gasto editado
  Future<void> _actualizarGasto(String gastoId) async {
    if (_formKey.currentState!.validate()) {
      final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0;

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      );

      try {
        final error = await _gastosServicio.actualizarGasto(
          gastoId: gastoId,
          descripcion: _descripcionController.text.trim(),
          monto: monto,
          fecha: _fechaSeleccionada ?? DateTime.now(),
          categoria: _categoriaSeleccionada,
          metodoPago: _metodoPagoSeleccionado,
          cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          esRecurrente: _esRecurrente,
          frecuencia: _esRecurrente ? _frecuenciaRecurrente : null,
          notas: '', // Puedes agregar campo de notas si lo necesitas
        );

        if (mounted) {
          Navigator.pop(context); // Cerrar indicador de carga
          Navigator.pop(context); // Cerrar formulario de edición

          if (error != null) {
            _mostrarError(error);
          } else {
            _limpiarFormulario();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Gasto actualizado correctamente'),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
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

  /// Widget para mostrar un ítem de detalle
  Widget _detalleItem(String titulo, String valor, {Color? color, bool italic = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta individual para mostrar un gasto
  Widget _buildTarjetaGastoSinCategoria(Map<String, dynamic> gasto, int index) {
    return GestureDetector(
      onTap: () => _mostrarDetalleGasto(gasto),
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gasto['descripcion'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (gasto['esRecurrente'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Recurrente',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gasto['metodoPago'].toString().substring(0, 1).toUpperCase()}${gasto['metodoPago'].toString().substring(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gasto['fecha'].day}/${gasto['fecha'].month}/${gasto['fecha'].year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (gasto['nota'] != null && gasto['nota'].isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      gasto['nota'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '-${FormatoNumeros.formatearParaMostrar(gasto['monto'])}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarGasto(gasto['id']),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(32, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un estado vacío cuando no hay gastos registrados
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.payment_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay gastos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primer gasto',
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

  /// Construye la tarjeta de resumen con el total de gastos
  Widget _buildResumenGastos() {
    final totalGastos = _gastos.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto['monto'],
    );

    // Eliminado cálculo por categoría

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade600,
            Colors.red.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade600.withOpacity(0.3),
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
                'Total de Gastos',
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
                  '${_gastos.length} registros',
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
            '\$${totalGastos.toStringAsFixed(2)}',
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

  /// Construye el gráfico de distribución de gastos por categoría
  Widget _buildGraficoGastos() {
    // Eliminado gráfico de distribución por categorías
    return const SizedBox.shrink();
  }

  /// Retorna el ícono correspondiente según la categoría del gasto
  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'alimentación':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'entretenimiento':
        return Icons.movie_rounded;
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'educación':
        return Icons.school_rounded;
      case 'servicios':
        return Icons.build_rounded;
      case 'compras':
        return Icons.shopping_bag_rounded;
      case 'viajes':
        return Icons.flight_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  /// Retorna el color correspondiente según la categoría del gasto para el gráfico
  // ...existing code...

  /// Abre el selector de fecha para elegir cuándo se realizó el gasto
  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      // locale eliminado para compatibilidad
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  /// Valida y guarda un nuevo gasto
  Future<void> _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      final monto = FormatoNumeros.convertirANumero(_montoController.text) ?? 0;
      
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      );

      try {
        // Registrar el gasto usando el servicio real
        final error = await _gastosServicio.crearGasto(
          descripcion: _descripcionController.text.trim(),
          monto: monto,
          fecha: _fechaSeleccionada ?? DateTime.now(),
          categoria: _categoriaSeleccionada,
          metodoPago: _metodoPagoSeleccionado,
          cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          esRecurrente: _esRecurrente,
          frecuencia: _esRecurrente ? _frecuenciaRecurrente : null,
          notas: '', // Puedes agregar un campo de notas si lo necesitas
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
    // ...eliminado clear de notaController...
    setState(() {
      _fechaSeleccionada = DateTime.now();
      _categoriaSeleccionada = 'alimentación';
      _metodoPagoSeleccionado = 'efectivo';
      _cuentaAsociada = 'ninguna';
      _esRecurrente = false;
      _frecuenciaRecurrente = 'mensual';
    });
  }

  /// Muestra un diálogo de confirmación para eliminar un gasto
  void _eliminarGasto(String gastoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
              );

              try {
                final error = await _gastosServicio.eliminarGasto(gastoId);
                
                if (mounted) {
                  // Cerrar indicador de carga
                  Navigator.pop(context);
                  
                  if (error != null) {
                    _mostrarError(error);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Gasto eliminado correctamente'),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Cerrar indicador de carga
                  _mostrarError('Error inesperado: ${e.toString()}');
                }
              }
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

  /// Muestra un mensaje de éxito cuando se registra un gasto correctamente
  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gasto registrado correctamente'),
        backgroundColor: Colors.red.shade600,
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
        title: const Text(
          'Gastos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF1F2937),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumenGastos(),
              const SizedBox(height: 24),
              if (_gastos.isNotEmpty) ...[
                _buildGraficoGastos(),
                const SizedBox(height: 32),
              ],
              _buildBarraBusqueda(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historial de Gastos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioGasto,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nuevo Gasto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildListaGastos(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Eliminado FloatingActionButton
    );
  }
}
