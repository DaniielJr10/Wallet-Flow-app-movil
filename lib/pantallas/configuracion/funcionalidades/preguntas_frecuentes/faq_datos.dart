import 'faq_modelos.dart';
import 'package:flutter/material.dart';

/// Datos de las preguntas frecuentes de Wallet Flow
class FAQDatos {
  static final List<PreguntaFrecuente> preguntasFrecuentes = [
    // CUENTAS
    PreguntaFrecuente(
      id: 'cuenta_01',
      categoria: 'Cuentas',
      pregunta: '¿Cómo agrego una nueva cuenta?',
      respuesta: 'Ve a "Cuentas" → toca "+" → completa los datos de tu cuenta (nombre, tipo, saldo) → guarda. Tu cuenta aparecerá inmediatamente.',
      palabrasClave: ['agregar', 'cuenta', 'nueva', 'crear'],
      icono: Icons.add_card,
      colorIcono: const Color(0xFF3B82F6),
    ),
    
    PreguntaFrecuente(
      id: 'cuenta_02',
      categoria: 'Cuentas',
      pregunta: '¿Por qué mi saldo no se actualiza solo?',
      respuesta: 'Por seguridad, no nos conectamos a tu banco. Debes registrar tus gastos e ingresos manualmente para mantener tu saldo actualizado.',
      palabrasClave: ['saldo', 'actualizar', 'automático', 'banco'],
      icono: Icons.refresh,
      colorIcono: const Color(0xFF3B82F6),
    ),

    // TRANSACCIONES
    PreguntaFrecuente(
      id: 'trans_01',
      categoria: 'Transacciones',
      pregunta: '¿Cómo registro un gasto o ingreso?',
      respuesta: 'Desde el inicio, toca "Nuevo Gasto" o "Nuevo Ingreso" → selecciona cuenta → ingresa monto y descripción → confirma.',
      palabrasClave: ['registrar', 'gasto', 'ingreso', 'transacción'],
      icono: Icons.add_circle,
      colorIcono: const Color(0xFF10B981),
    ),
    
    PreguntaFrecuente(
      id: 'trans_02',
      categoria: 'Transacciones',
      pregunta: '¿Cómo transfiero entre mis cuentas?',
      respuesta: 'Ve a "Cuentas" → selecciona cuenta origen → "Transferir" → elige cuenta destino → ingresa monto → confirma.',
      palabrasClave: ['transferir', 'entre cuentas', 'mover dinero'],
      icono: Icons.compare_arrows,
      colorIcono: const Color(0xFF10B981),
    ),

    // DEUDAS
    PreguntaFrecuente(
      id: 'deuda_01',
      categoria: 'Deudas',
      pregunta: '¿Cómo registro una nueva deuda?',
      respuesta: 'Ve a "Deudas" → toca "+" → completa datos (acreedor, monto, fecha límite) → guarda. Podrás ver tu progreso de pago.',
      palabrasClave: ['deuda', 'nueva', 'agregar'],
      icono: Icons.credit_card_outlined,
      colorIcono: const Color(0xFFEF4444),
    ),
    
    PreguntaFrecuente(
      id: 'deuda_02',
      categoria: 'Deudas',
      pregunta: '¿Cómo pago una deuda?',
      respuesta: 'En la lista de deudas → toca la deuda → "Pagar" → elige cuenta → ingresa monto → confirma. Los saldos se actualizan automáticamente.',
      palabrasClave: ['pago', 'pagar', 'abono'],
      icono: Icons.payment,
      colorIcono: const Color(0xFFEF4444),
    ),

    // AHORROS
    PreguntaFrecuente(
      id: 'ahorro_01',
      categoria: 'Ahorros',
      pregunta: '¿Cómo creo una meta de ahorro?',
      respuesta: 'Ve a "Ahorros" → "Nueva Meta" → define objetivo (nombre, monto, fecha) → guarda. Verás tu progreso actualizado.',
      palabrasClave: ['meta', 'ahorro', 'objetivo', 'crear'],
      icono: Icons.flag,
      colorIcono: const Color(0xFF8B5CF6),
    ),
    
    PreguntaFrecuente(
      id: 'ahorro_02',
      categoria: 'Ahorros',
      pregunta: '¿Cómo agrego dinero a mi meta?',
      respuesta: 'Selecciona la meta → "Agregar Dinero" → ingresa monto → confirma. El progreso se actualiza inmediatamente.',
      palabrasClave: ['agregar', 'dinero', 'meta', 'progreso'],
      icono: Icons.add_box,
      colorIcono: const Color(0xFF8B5CF6),
    ),

    // SEGURIDAD
    PreguntaFrecuente(
      id: 'seg_01',
      categoria: 'Seguridad',
      pregunta: '¿Mis datos están seguros?',
      respuesta: 'Sí. Usamos cifrado avanzado, no guardamos datos bancarios reales, y solo tú puedes ver tu información.',
      palabrasClave: ['seguridad', 'datos', 'cifrado', 'protección'],
      icono: Icons.shield,
      colorIcono: const Color(0xFFF59E0B),
    ),
    
    PreguntaFrecuente(
      id: 'seg_02',
      categoria: 'Seguridad',
      pregunta: '¿Cómo cambio mi contraseña?',
      respuesta: 'Ve a Configuración → "Cambiar Contraseña" → ingresa contraseña actual → nueva contraseña → confirma.',
      palabrasClave: ['cambiar', 'contraseña', 'seguridad'],
      icono: Icons.lock_reset,
      colorIcono: const Color(0xFFF59E0B),
    ),

    // EXPORTAR
    PreguntaFrecuente(
      id: 'exp_01',
      categoria: 'Reportes',
      pregunta: '¿Puedo exportar mis datos?',
      respuesta: 'Sí. Ve a Herramientas → "Exportar Datos" → elige período y formato (CSV/PDF) → "Generar" → descarga.',
      palabrasClave: ['exportar', 'datos', 'CSV', 'PDF', 'reporte'],
      icono: Icons.file_download,
      colorIcono: const Color(0xFF06B6D4),
    ),

    // GENERAL
    PreguntaFrecuente(
      id: 'gen_01',
      categoria: 'General',
      pregunta: '¿Funciona sin internet?',
      respuesta: 'Puedes consultar datos previamente cargados. Necesitas internet para sincronizar y hacer respaldos.',
      palabrasClave: ['internet', 'offline', 'sin conexión'],
      icono: Icons.cloud_off,
      colorIcono: const Color(0xFF84CC16),
    ),
    
    PreguntaFrecuente(
      id: 'gen_02',
      categoria: 'General',
      pregunta: '¿Olvidé mi contraseña, qué hago?',
      respuesta: 'En inicio de sesión → "¿Olvidaste tu contraseña?" → ingresa tu email → revisa correo → sigue el enlace → crea nueva contraseña.',
      palabrasClave: ['recuperar', 'olvide', 'contraseña', 'email'],
      icono: Icons.help_outline,
      colorIcono: const Color(0xFF84CC16),
    ),
  ];

  /// Obtiene todas las categorías disponibles
  static List<String> obtenerCategorias() {
    return CategoriaFAQ.values.map((categoria) => categoria.nombre).toList();
  }

  /// Filtra preguntas por categoría
  static List<PreguntaFrecuente> filtrarPorCategoria(String categoria) {
    if (categoria.isEmpty) return preguntasFrecuentes;
    return preguntasFrecuentes
        .where((pregunta) => pregunta.categoria == categoria)
        .toList();
  }

  /// Busca preguntas por término
  static List<PreguntaFrecuente> buscarPreguntas(String termino) {
    if (termino.isEmpty) return preguntasFrecuentes;
    
    final terminoLower = termino.toLowerCase();
    return preguntasFrecuentes.where((pregunta) {
      return pregunta.pregunta.toLowerCase().contains(terminoLower) ||
             pregunta.respuesta.toLowerCase().contains(terminoLower) ||
             pregunta.palabrasClave.any((palabra) => 
                 palabra.toLowerCase().contains(terminoLower)) ||
             pregunta.categoria.toLowerCase().contains(terminoLower);
    }).toList();
  }

  /// Obtiene preguntas por categoría enum
  static List<PreguntaFrecuente> obtenerPorCategoriaEnum(CategoriaFAQ categoria) {
    return preguntasFrecuentes
        .where((pregunta) => pregunta.categoria == categoria.nombre)
        .toList();
  }
}