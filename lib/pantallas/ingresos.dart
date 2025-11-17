import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _categoriaSeleccionada = 'trabajo';
  String _metodoPagoSeleccionado = 'Efectivo';
  String _cuentaAsociada = 'ninguna';

  String _busqueda = '';
  bool _editandoIngreso = false;
  Map<String, dynamic>? _ingresoEnEdicion;
  StateSetter? _setModalState;


  final List<String> _categorias = [
    'trabajo',
    'negocio',
    'freelance',
    'inversiones',
    'regalo',
    'ventas',
    'renta',
    'bonificacion',
    'otro'
  ];

  final List<String> _metodosPago = [
  'Efectivo',
  'Transferencia'
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
    _inicializarIngresos();
  }

  /// Libera los recursos utilizados por los controladores y animaciones
  @override
  void dispose() {
    _animationController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Inicializa la carga de ingresos desde Firebase
  void _inicializarIngresos() {
    // Los ingresos se cargan automáticamente mediante StreamBuilder en la UI
  }



  /// Muestra el modal con el formulario para registrar un nuevo ingreso
  void _mostrarFormularioIngreso([Map<String, dynamic>? ingresoAEditar]) {
    _editandoIngreso = ingresoAEditar != null;
    _ingresoEnEdicion = ingresoAEditar;
    
    // Si estamos editando, llenar los campos con los datos existentes
    if (_editandoIngreso && _ingresoEnEdicion != null) {
      _montoController.text = FormatoNumeros.formatearParaMostrar(_ingresoEnEdicion!['monto']);
      _descripcionController.text = _ingresoEnEdicion!['descripcion'];
      _fechaSeleccionada = _ingresoEnEdicion!['fecha'];
      _categoriaSeleccionada = _ingresoEnEdicion!['categoria'];
      _metodoPagoSeleccionado = _ingresoEnEdicion!['metodoPago'];
      _cuentaAsociada = _ingresoEnEdicion!['cuentaAsociada'] ?? 'ninguna';
    } else {
      // Limpiar para nuevo ingreso
      _limpiarFormulario();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return _buildFormularioModalConEstado(setModalState);
        },
      ),
    );
  }

  /// Muestra el modal con los detalles completos del ingreso
  void _mostrarDetallesIngreso(Map<String, dynamic> ingreso) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalDetalles(ingreso),
    );
  }

  /// Construye el modal que contiene el formulario de nuevo ingreso con estado
  Widget _buildFormularioModalConEstado(StateSetter setModalState) {
    _setModalState = setModalState;
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
                  Expanded(
                    child: Text(
                      _editandoIngreso ? 'Editar Ingreso' : 'Nuevo Ingreso',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    if (mounted) Navigator.pop(context);
                  },
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

  /// Construye el modal que muestra los detalles completos del ingreso
  Widget _buildModalDetalles(Map<String, dynamic> ingreso) {

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header del modal
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconoCategoria(ingreso['categoria']),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles del Ingreso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ingreso['descripcion'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
          
          // Contenido de los detalles
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monto principal
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2ecc71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFF2ecc71), width: 2),
                      ),
                      child: Text(
                        '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2ecc71),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Grid de detalles
                  _buildDetalleItem(
                    'Descripción',
                    ingreso['descripcion'],
                    Icons.description_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetalleItem(
                    'Categoría',
                    '${ingreso['categoria'].toString().substring(0, 1).toUpperCase()}${ingreso['categoria'].toString().substring(1)}',
                    Icons.category_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetalleItem(
                    'Método de Pago',
                    '${ingreso['metodoPago'].toString().substring(0, 1).toUpperCase()}${ingreso['metodoPago'].toString().substring(1)}',
                    Icons.payment_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetalleItem(
                    'Fecha',
                    '${ingreso['fecha'].day} de ${_getNombreMes(ingreso['fecha'].month)} de ${ingreso['fecha'].year}',
                    Icons.calendar_today_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetalleItem(
                    'Cuenta Asociada',
                    ingreso['cuentaAsociada'] == null || ingreso['cuentaAsociada'] == 'ninguna' 
                        ? 'Ninguna cuenta asociada' 
                        : 'Cuenta vinculada',
                    Icons.account_balance_outlined,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editarIngreso(ingreso);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmarEliminarIngreso(ingreso);
                    },
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de detalle con icono, título y valor
  Widget _buildDetalleItem(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2ecc71).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: Color(0xFF2ecc71),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el nombre del mes en español
  String _getNombreMes(int mes) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return meses[mes - 1];
  }

    /// Inicia la edición de un ingreso
    void _editarIngreso(Map<String, dynamic> ingreso) {
      _mostrarFormularioIngreso(ingreso);
    }

    /// Muestra un diálogo de confirmación antes de eliminar
    void _confirmarEliminarIngreso(Map<String, dynamic> ingreso) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar ingreso'),
          content: const Text('¿Estás seguro de que deseas eliminar este ingreso? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _eliminarIngreso(ingreso);
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    }

    /// Elimina el ingreso usando Firebase
    Future<void> _eliminarIngreso(Map<String, dynamic> ingreso) async {
      try {
        final ingresoId = ingreso['id'] as String;
        final resultado = await _ingresosServicio.eliminarIngreso(ingresoId);
        
        if (resultado == null) {
          // Éxito
          _mostrarMensajeExitoEliminar();
        } else {
          // Error
          _mostrarError('Error al eliminar: $resultado');
        }
      } catch (e) {
        _mostrarError('Error inesperado: $e');
      }
    }

    /// Muestra mensaje de éxito al eliminar
    void _mostrarMensajeExitoEliminar() {
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
    }

  /// Construye el campo de entrada para el monto del ingreso
  Widget _buildCampoMonto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Monto',
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
            hintText: '',
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
            'Descripción',
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
            hintText: '',
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
        DropdownButtonFormField<String>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          items: _categorias.map((categoria) {
            return DropdownMenuItem(
              value: categoria,
              child: Row(
                children: [
                  Icon(
                    _getIconoCategoria(categoria),
                    color: Color(0xFF2ecc71),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2ecc71), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: _metodosPago.map((metodo) {
            return DropdownMenuItem(
              value: metodo,
              child: Row(
                children: [
                  Icon(
                    metodo == 'Efectivo' ? Icons.money_rounded : Icons.credit_card_rounded,
                    color: Color(0xFF2ecc71),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    metodo,
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
              _metodoPagoSeleccionado = value!;
            });
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
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2ecc71), size: 20),
                    SizedBox(width: 12),
                    Text('Ninguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ];
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              items.add(const DropdownMenuItem(
                value: 'cargando',
                child: Text('Cargando cuentas...', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ));
            } else if (snapshot.hasError) {
              items.add(const DropdownMenuItem(
                value: 'error',
                child: Text('Error al cargar cuentas', style: TextStyle(fontSize: 16, color: Colors.red)),
              ));
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
                    
                    String displayName;
                    if (alias != null && alias.isNotEmpty) {
                      displayName = '$alias ($banco)';
                    } else {
                      displayName = '$banco - $numero';
                    }
                    
                    items.add(DropdownMenuItem(
                      value: cuentaId,
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: Color(0xFF2ecc71), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ));
                  }
                } catch (e) {
                  continue;
                }
              }
            }
            
            // Verificar que el valor actual sea válido
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2ecc71), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: items,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != _cuentaAsociada && newValue != 'cargando' && newValue != 'error') {
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
            child: Text(
              _editandoIngreso ? 'Actualizar' : 'Guardar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la lista de ingresos registrados usando StreamBuilder con Firebase
  Widget _buildListaIngresos() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ingresosServicio.obtenerIngresos(),
      builder: (context, snapshot) {
        // Estados de carga y error
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar ingresos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, inténtalo de nuevo',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Forzar reconstrucción
                    });
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Obtener datos de ingresos
        final ingresos = snapshot.data ?? [];
        
        // Aplicar filtros locales
        final ingresosFiltrados = _aplicarFiltros(ingresos);

        // Estado vacío
        if (ingresosFiltrados.isEmpty) {
          return _buildEstadoVacio();
        }

        // Lista con datos
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingresosFiltrados.length,
          itemBuilder: (context, index) {
            final ingreso = ingresosFiltrados[index];
            return _buildTarjetaIngreso(ingreso, index);
          },
        );
      },
    );
  }

  /// Aplica filtros de búsqueda a la lista de ingresos
  List<Map<String, dynamic>> _aplicarFiltros(List<Map<String, dynamic>> ingresos) {
    if (_busqueda.isEmpty) return ingresos;

    return ingresos.where((ingreso) {
      bool coincideBusqueda = true;
      
      if (_modoBusqueda == 'categoría') {
        final categoria = ingreso['categoria']?.toString().toLowerCase() ?? '';
        coincideBusqueda = categoria.contains(_busqueda.toLowerCase());
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
      
      return coincideBusqueda;
    }).toList();
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _mostrarDetallesIngreso(ingreso),
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
          trailing: SizedBox(
            width: 120, // Ancho fijo para evitar overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${FormatoNumeros.formatearParaMostrar(ingreso['monto'])}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2ecc71),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
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

  /// Construye la tarjeta de resumen con el total de ingresos usando StreamBuilder
  Widget _buildResumenIngresos() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ingresosServicio.obtenerIngresos(),
      builder: (context, snapshot) {
        // Calcular totales con los datos del snapshot
        final ingresos = snapshot.data ?? [];
        final totalIngresos = ingresos.fold<double>(
          0.0,
          (sum, ingreso) => sum + (ingreso['monto'] as num).toDouble(),
        );

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
                      '${ingresos.length} registros',
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
                FormatoNumeros.formatearParaMostrar(totalIngresos),
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
      },
    );
  }

  /// Retorna el ícono correspondiente según la categoría del ingreso
  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'trabajo':
        return Icons.work_rounded;
      case 'negocio':
        return Icons.business_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'inversiones':
        return Icons.trending_up_rounded;
      case 'regalo':
        return Icons.card_giftcard_rounded;
      case 'ventas':
        return Icons.sell_rounded;
      case 'renta':
        return Icons.house_rounded;
      case 'bonificacion':
        return Icons.star_rounded;
      case 'otro':
        return Icons.attach_money_rounded;
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
      lastDate: DateTime(2030), // Permitir fechas hasta el año 2030
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
      
      // Actualizar también el estado del modal si está disponible
      if (_setModalState != null) {
        _setModalState!(() {
          _fechaSeleccionada = fecha;
        });
      }
    }
  }

  /// Valida y guarda un nuevo ingreso o actualiza uno existente
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
        String? error;
        
        if (_editandoIngreso && _ingresoEnEdicion != null) {
          // === ACTUALIZAR INGRESO EXISTENTE ===
          error = await _ingresosServicio.actualizarIngreso(
            ingresoId: _ingresoEnEdicion!['id'],
            monto: monto,
            fecha: _fechaSeleccionada ?? DateTime.now(),
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
            metodoPago: _metodoPagoSeleccionado,
            cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          );
        } else {
          // === CREAR NUEVO INGRESO ===
          error = await _ingresosServicio.registrarIngreso(
            monto: monto,
            fecha: _fechaSeleccionada ?? DateTime.now(),
            descripcion: _descripcionController.text.trim(),
            categoria: _categoriaSeleccionada,
            metodoPago: _metodoPagoSeleccionado,
            cuentaAsociada: _cuentaAsociada != 'ninguna' ? _cuentaAsociada : null,
          );
        }

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
            
            if (_editandoIngreso) {
              _mostrarMensajeActualizacion();
            } else {
              _mostrarMensajeExito();
            }
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
      _metodoPagoSeleccionado = 'Efectivo';
      _cuentaAsociada = 'ninguna';
      _editandoIngreso = false;
      _ingresoEnEdicion = null;
    });
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

  /// Muestra un mensaje de éxito cuando se actualiza un ingreso correctamente
  void _mostrarMensajeActualizacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ingreso actualizado correctamente'),
        backgroundColor: Colors.blue.shade600,
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
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'INGRESOS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
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
                  const Expanded(
                    child: Text(
                      'Historial de Ingresos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioIngreso,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ecc71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
