# Sistema de Notificaciones de Deudas ⚡ AUTOMÁTICO

Este sistema proporciona notificaciones automáticas cuando las deudas están próximas a vencer o ya han vencido.
**¡NO REQUIERE INICIALIZACIÓN MANUAL! Se configura automáticamente cuando lo usas.**

## Características principales

- ✅ **COMPLETAMENTE AUTOMÁTICO** - No necesitas inicializar nada manualmente
- ✅ Notificaciones programadas automáticamente
- ✅ Alertas múltiples por deuda (7, 3 y 1 día antes del vencimiento)
- ✅ Notificaciones inmediatas para deudas que vencen el día actual
- ✅ Widgets de UI para mostrar alertas en la aplicación
- ✅ Sistema de gestión centralizado
- ✅ Configuración personalizable
- ✅ Auto-inicialización inteligente

## Estructura de archivos

```
notificaciones/
├── servicio_notificaciones_deudas.dart     # Servicio base para notificaciones locales
├── gestor_notificaciones_deudas.dart       # Gestor principal del sistema
├── widgets_notificaciones.dart             # Widgets de UI para mostrar alertas
├── inicializador_notificaciones.dart       # Inicializador del sistema
├── configuracion_notificaciones.dart       # Configuraciones y constantes
├── notificaciones_deudas.dart              # Archivo de índice para exportaciones
└── README.md                               # Esta documentación
```

## Instalación de dependencias

Para que funcione correctamente, necesitas agregar estas dependencias a tu `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
```

Para Android, también necesitas los permisos en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Uso básico ⚡ SÚPER FÁCIL

### ¡No necesitas inicializar nada! Solo úsalo directamente:

### 1. Agregar una deuda al sistema (se inicializa automáticamente)

```dart
// ¡Simplemente úsalo! Se inicializa automáticamente
final gestor = GestorNotificacionesDeudas();

final deuda = DeudaNotificacion(
  id: 1,
  nombre: 'Pago de tarjeta de crédito',
  monto: 1500.00,
  fechaVencimiento: DateTime.now().add(Duration(days: 5)),
  activa: true,
);

await gestor.agregarDeuda(deuda); // ¡Automático! ⚡
```

### 2. Configurar múltiples deudas (también automático)

```dart
final deudas = [
  {
    'id': 1,
    'nombre': 'Tarjeta de crédito',
    'monto': 1500.00,
    'fechaVencimiento': DateTime.now().add(Duration(days: 5)),
    'activa': true,
  },
  {
    'id': 2,
    'nombre': 'Préstamo personal',
    'monto': 800.00,
    'fechaVencimiento': DateTime.now().add(Duration(days: 10)),
    'activa': true,
  },
];

await NotificacionesDeudas.configurarParaDeudas(deudas); // ¡Automático! ⚡
```

### 3. Mostrar alertas en la UI (sin configuración previa)

```dart
// Widget de alertas completas
AlertasDeudas(
  mostrarSoloUrgentes: false,
  onDeudaTocada: () {
    // Navegar a la pantalla de detalles
  },
)

// Widget de contador compacto
ContadorAlertasDeudas(
  onTap: () {
    // Mostrar pantalla de alertas
  },
)

// Widget de resumen de estadísticas
ResumenNotificaciones()
```

## Funcionalidades avanzadas

### Personalización de días de anticipación

```dart
await gestor.programarNotificacionesMultiples(
  idBase: deuda.id * 100,
  nombreDeuda: deuda.nombre,
  monto: deuda.monto,
  fechaVencimiento: deuda.fechaVencimiento,
  diasAnticipacion: [14, 7, 3, 1], // Personalizado
);
```

### Verificación manual del estado

```dart
final gestor = GestorNotificacionesDeudas();

// Enviar notificaciones inmediatas para deudas urgentes
await gestor.verificarEstadoDeudas();

// Obtener estadísticas
final stats = await gestor.obtenerEstadisticas();
print('Deudas próximas a vencer: ${stats['deudasProximasAVencer']}');
```

### Manejo de notificaciones

```dart
final servicio = ServicioNotificacionesDeudas();

// Cancelar notificación específica
await servicio.cancelarNotificacion(123);

// Cancelar todas las notificaciones de una deuda
await gestor.cancelarNotificacionesDeuda(deudaId);

// Ver notificaciones pendientes
final pendientes = await servicio.obtenerNotificacionesPendientes();
```

## Configuración

### Personalizar colores y estilos

Edita `configuracion_notificaciones.dart`:

```dart
class ConfiguracionNotificacionesDeudas {
  static const int colorNotificacion = 0xFFFF5722; // Tu color personalizado
  static const List<int> diasAnticipacionPorDefecto = [14, 7, 3, 1]; // Tus días
  static const int horaNotificacion = 10; // Hora personalizada (10:00 AM)
}
```

### Personalizar mensajes

```dart
// Título personalizado
static String generarTituloCompleto(int diasRestantes) {
  final emoji = obtenerEmoji(diasRestantes);
  return '$emoji Mi mensaje personalizado';
}
```

## Integración con el resto de la app

### En la pantalla principal de deudas

```dart
class PantallaDeudas extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Mostrar alertas en la parte superior
          AlertasDeudas(
            mostrarSoloUrgentes: true,
            onDeudaTocada: () => _navegarADetalle(),
          ),
          
          // Resto del contenido de deudas
          Expanded(
            child: ListaDeudas(),
          ),
        ],
      ),
    );
  }
}
```

### En el AppBar

```dart
AppBar(
  title: Text('Mis Deudas'),
  actions: [
    ContadorAlertasDeudas(
      onTap: () => _mostrarAlertas(),
    ),
  ],
)
```

## Testing

Crear una deuda de prueba:

```dart
await NotificacionesDeudas.crearDeudaDePrueba();
```

## Troubleshooting

### Las notificaciones no aparecen
- Verifica que los permisos estén configurados correctamente
- Asegúrate de que la app esté inicializada antes de programar notificaciones
- Revisa que las fechas de vencimiento sean futuras

### Error de timezone
- Asegúrate de importar `timezone` correctamente
- Inicializa las zonas horarias con `tz.initializeTimeZones()`

### Problemas de rendimiento
- Usa `mostrarSoloUrgentes: true` en widgets para mostrar menos información
- Limpia notificaciones de deudas eliminadas regularmente

## Próximas mejoras

- [ ] Notificaciones push remotas
- [ ] Configuración de horarios por usuario
- [ ] Integración con calendario
- [ ] Recordatorios personalizables por deuda
- [ ] Estadísticas avanzadas de notificaciones
