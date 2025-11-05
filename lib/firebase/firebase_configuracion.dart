/// Configuraciones y constantes para Firebase
/// Aquí están todas las configuraciones importantes de la app
class FirebaseConfiguracion {
  
  /// COLECCIONES DE FIRESTORE
  static const String coleccionUsuarios = 'usuarios';
  static const String coleccionAhorros = 'ahorros';
  static const String coleccionGastos = 'gastos';
  static const String coleccionCuentas = 'cuentas';
  static const String coleccionDeudas = 'deudas';
  static const String coleccionPresupuestos = 'presupuestos';
  static const String coleccionIngresos = 'ingresos';
  static const String coleccionInversiones = 'inversiones';
  static const String coleccionObjetivos = 'objetivos';
  static const String coleccionNotificaciones = 'notificaciones';
  
  /// CATEGORÍAS PREDEFINIDAS
  static const List<String> categoriasGastos = [
    'Alimentación',
    'Transporte', 
    'Entretenimiento',
    'Servicios',
    'Compras',
    'Salud',
    'Educación',
    'Viajes',
    'Otros'
  ];
  
  static const List<String> categoriasIngresos = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Ventas',
    'Bonos',
    'Otros'
  ];
  
  static const List<String> categoriasAhorros = [
    'Emergencia',
    'Vacaciones',
    'Compra Casa',
    'Compra Auto',
    'Educación',
    'Retiro',
    'Otros'
  ];
  
  /// TIPOS DE CUENTA
  static const List<String> tiposCuenta = [
    'Ahorros',
    'Corriente',
    'Nómina',
    'Inversión'
  ];
  
  /// MÉTODOS DE PAGO
  static const List<String> metodosPago = [
    'Efectivo',
    'Tarjeta Débito',
    'Tarjeta Crédito',
    'Transferencia',
    'PayPal',
    'Otros'
  ];
  
  /// ESTADOS DE AHORRO
  static const String estadoPendiente = 'pendiente';
  static const String estadoCumplido = 'cumplido';
  static const String estadoIncumplido = 'incumplido';
  
  /// ESTADOS DE DEUDA
  static const String deudaPendiente = 'pendiente';
  static const String deudaPagada = 'pagada';
  static const String deudaVencida = 'vencida';
  
  /// CONFIGURACIÓN DE VALIDACIÓN
  static const int longitudMinimaPassword = 8;
  static const int longitudMaximaTexto = 100;
  static const double montoMinimo = 0.01;
  static const double montoMaximo = 999999999.99;
  
  /// MENSAJES DE ERROR COMUNES
  static const String errorSinInternet = 'Sin conexión a internet';
  static const String errorUsuarioNoAutenticado = 'Usuario no autenticado';
  static const String errorDatosIncompletos = 'Todos los campos son obligatorios';
  static const String errorMontoInvalido = 'El monto debe ser mayor a 0';
  
  /// MENSAJES DE ÉXITO
  static const String exitoAhorroCreado = 'Ahorro creado exitosamente';
  static const String exitoGastoCreado = 'Gasto registrado exitosamente';
  static const String exitoCuentaCreada = 'Cuenta bancaria agregada exitosamente';
  static const String exitoDeudaCreada = 'Deuda registrada exitosamente';
  static const String exitoPerfilActualizado = 'Perfil actualizado exitosamente';
}