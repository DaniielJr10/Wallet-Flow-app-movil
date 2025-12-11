# 🏦 Sistema de Notificaciones para Ahorros

Este sistema maneja automáticamente todas las notificaciones relacionadas con metas de ahorro y recordatorios de ahorro en la aplicación.

## ✨ Características Principales

- **🚀 Auto-inicializable**: No requiere configuración manual
- **🎯 Recordatorios de metas**: Notificaciones periódicas según progreso
- **⏰ Alertas de vencimiento**: Avisos cuando una meta está por vencer  
- **🎉 Notificaciones de éxito**: Celebra cuando se completa una meta
- **📊 Sistema de estadísticas**: Monitoreo completo del sistema
- **🔧 Configuración flexible**: El usuario puede activar/desactivar

## 📁 Estructura de Archivos

```
notificaciones/
├── servicio_notificaciones_ahorros.dart     # Servicio base para notificaciones locales
├── gestor_notificaciones_ahorros.dart       # Gestor principal del sistema
├── widgets_notificaciones.dart              # Widgets de UI para mostrar estado
├── inicializador_notificaciones.dart        # Auto-inicializador del sistema
├── configuracion_notificaciones.dart        # Configuraciones y constantes
├── notificaciones_ahorros.dart              # Archivo de índice para exportaciones
└── README.md                                # Esta documentación
```

## 🚀 Cómo Usar

### Importación Simple
```dart
import 'funcionalidades/notificaciones/notificaciones_ahorros.dart';
```

### Crear Meta con Notificaciones
```dart
// Se configuran automáticamente todos los recordatorios y alertas
await NotificacionesAhorros.crearMetaConNotificaciones(
  metaId: 1,
  nombreMeta: "Viaje a Europa",
  montoObjetivo: 5000.0,
  fechaLimite: DateTime(2025, 12, 31),
  frecuenciaRecordatorio: 'semanal', // 'diario', 'semanal', 'mensual'
);
```

### Actualizar Progreso
```dart
// Auto-detecta si se completó la meta y envía notificación de éxito
await NotificacionesAhorros.actualizarProgreso(
  metaId: 1,
  nombreMeta: "Viaje a Europa",
  montoObjetivo: 5000.0,
  nuevoMontoActual: 3500.0, // 70% completado
  fechaLimite: DateTime(2025, 12, 31),
);
```

### Configuración del Sistema
```dart
// Activar/desactivar notificaciones
await NotificacionesAhorros.configurarSistema(true);  // Activar
await NotificacionesAhorros.configurarSistema(false); // Desactivar

// Verificar si están activas
final activas = await NotificacionesAhorros.estanActivas();

// Limpiar todas las notificaciones programadas
await NotificacionesAhorros.limpiarSistema();
```

## 🎯 Tipos de Notificaciones

### 1. **Recordatorios Periódicos**
- Se envían según la frecuencia configurada (diario/semanal/mensual)
- Mensaje personalizado según el progreso actual
- Motivan a continuar ahorrando

### 2. **Alertas de Vencimiento**
- Se envían 7, 3 y 1 días antes del vencimiento
- Solo si la meta no está completada
- Incluyen información de cuánto falta

### 3. **Notificaciones de Éxito**
- Se envían automáticamente cuando se completa una meta
- Celebran el logro del usuario
- Cancelan recordatorios pendientes

### 4. **Recordatorios Generales**
- Para usuarios sin metas activas
- Motivan a crear nuevas metas de ahorro

## 📱 Widgets de Interfaz

### Indicador de Estado
```dart
// Muestra si las notificaciones están activas
WidgetsNotificacionesAhorros.indicadorEstado(
  context: context,
  mostrarTexto: true,
)
```

### Switch de Activación
```dart
// Switch para activar/desactivar
WidgetsNotificacionesAhorros.switchNotificaciones(
  context: context,
  onChanged: (valor) => print('Notificaciones: $valor'),
  titulo: 'Recordatorios de Metas',
)
```

### Tarjeta de Estadísticas
```dart
// Muestra estadísticas completas
WidgetsNotificacionesAhorros.tarjetaEstadisticas(
  context: context,
)
```

### Configuración Avanzada
```dart
// Panel completo de configuración
WidgetsNotificacionesAhorros.configuracionAvanzada(
  context: context,
)
```

## ⚙️ Configuración Interna

### Frecuencias Disponibles
- **Diario**: Recordatorios diarios a las 10:00 AM
- **Semanal**: Recordatorios semanales los domingos a las 9:00 AM  
- **Mensual**: Recordatorios mensuales el día 1 a las 8:00 AM

### Rangos de IDs
- **Metas**: 10000 en adelante
- **Recordatorios generales**: 999999

### Colores por Tipo
- **Recordatorios**: Verde (#10B981)
- **Éxito**: Verde éxito (#22C55E)
- **Alertas**: Ámbar (#F59E0B)
- **Progreso**: Azul (#3B82F6)

## 📊 Estadísticas y Monitoreo

```dart
// Obtener estadísticas completas
final estadisticas = await NotificacionesAhorros.obtenerEstadisticas();

// Verificar si todo funciona correctamente
final funcionando = await NotificacionesAhorros.estaFuncionando();

// Ejecutar prueba del sistema
final pruebaExitosa = await NotificacionesAhorros.ejecutarPrueba();
```

## 🔧 Integración con Configuración General

El sistema se integra automáticamente con la pantalla de configuración de notificaciones:

```dart
// Se conecta automáticamente cuando el usuario cambia la configuración
// desde la pantalla: Configuración → Notificaciones → Ahorros
```

## 📝 Mensajes Personalizados

Los mensajes se adaptan automáticamente según el progreso:

- **0-24%**: "Recordatorio: tu meta te está esperando..."
- **25-49%**: "Buen comienzo con el X%..."  
- **50-69%**: "¡A medio camino! Ya tienes el X%..."
- **70-89%**: "¡Vas muy bien! Has completado el X%..."
- **90%+**: "¡Ya casi lo logras! Solo faltan $X..."

## ✅ Estado del Sistema

- ✅ **Auto-inicialización**: Funciona automáticamente
- ✅ **Gestión de metas**: Crear, actualizar, eliminar  
- ✅ **Widgets de UI**: Indicadores y controles
- ✅ **Integración**: Conecta con sistema de configuración
- ✅ **Notificaciones locales**: Android e iOS
- ✅ **Persistencia**: Configuraciones guardadas
- ✅ **Sistema de pruebas**: Validación automática

## 🚀 Uso Rápido

```dart
// Importar una sola línea
import 'funcionalidades/notificaciones/notificaciones_ahorros.dart';

// Ya está listo para usar - sin configuración adicional!
await NotificacionesAhorros.crearMetaConNotificaciones(
  metaId: 123,
  nombreMeta: "Mi Meta",
  montoObjetivo: 1000.0,
  fechaLimite: DateTime.now().add(Duration(days: 30)),
);
```

¡El sistema está listo para usar inmediatamente después de la importación! 🎉
