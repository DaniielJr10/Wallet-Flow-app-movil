# 📱 Sistema de Notificaciones para Ingresos Frecuentes

## 🎯 Funcionalidad Principal
Cuando el usuario crea un ingreso y lo marca como **frecuente** (semanal, quincenal o mensual), el sistema automáticamente:

1. **Programa una notificación** para el día que corresponde según la frecuencia
2. **Recuerda al usuario** registrar ese ingreso con un mensaje personalizado
3. **Permite gestionar** las notificaciones desde la configuración de la app

## 🏗️ Arquitectura del Sistema

### 📂 Estructura de Archivos
```
lib/firebase/servicios/NotificacionesService/
├── notificaciones_servicio.dart          # Servicio principal (Singleton)
└── funcionalidades/
    ├── configuracion_notificaciones.dart  # Setup, permisos, canales
    ├── programacion_notificaciones.dart   # Schedule de notificaciones
    └── utils_notificaciones.dart         # Utilidades y helpers
```

### 🔧 Componentes Principales

#### 1. **NotificacionesServicio** (Singleton)
- Punto de entrada único para todas las operaciones
- Combina todas las funcionalidades en una interfaz limpia
- Se inicializa en `main.dart`

#### 2. **ConfiguracionNotificaciones**
- Maneja la inicialización del plugin
- Configura canales para Android
- Gestiona permisos del usuario
- Guarda preferencias en SharedPreferences

#### 3. **ProgramacionNotificaciones**
- Programa notificaciones para fechas específicas
- Maneja timezone y fechas futuras
- Cancela notificaciones cuando es necesario
- Formatea mensajes personalizados

#### 4. **UtilsNotificaciones**
- Genera IDs únicos para cada notificación
- Formatea mensajes con montos y descripciones
- Calcula fechas futuras según frecuencia
- Validaciones y helpers

## 🚀 Flujo de Funcionamiento

### Cuando se crea un ingreso frecuente:

1. **Usuario llena formulario** → Selecciona frecuencia (semanal/quincenal/mensual)
2. **FrecuenciaServicio.crearIngresoConFrecuencia()** → Se ejecuta
3. **Se guarda en Firestore** → Con campos de repetición
4. **Se calcula próxima fecha** → Según la frecuencia seleccionada
5. **Se programa notificación** → Para la fecha calculada
6. **Usuario recibe recordatorio** → En la fecha programada

### Mensaje de notificación ejemplo:
```
💰 Recordatorio de Ingreso
Es hora de registrar tu ingreso de $1.500.000 por Salario Mensual
```

## ⚙️ Configuración del Usuario

El usuario puede:
- **Activar/desactivar** notificaciones desde Configuración
- **Ver estado** de las notificaciones en tiempo real
- **Cancelar todas** las notificaciones al desactivar

## 🔧 Integración con el Sistema Existente

### Archivos modificados:
- `pubspec.yaml` → Agregadas dependencias
- `main.dart` → Inicialización del servicio
- `frecuencia_servicio.dart` → Programación de notificaciones
- `configuracion.dart` → Control desde configuración

### Dependencias agregadas:
```yaml
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
```

## 🎨 Buenas Prácticas Implementadas

- **Código modular** → Cada responsabilidad en archivo separado
- **Manejo de errores** → Try-catch en todas las operaciones
- **Singleton pattern** → Una sola instancia del servicio
- **Async/await** → Para operaciones no bloqueantes
- **Logging** → Para debugging y monitoreo

## 📱 Compatibilidad
- ✅ **Android** → Canales de notificación configurados
- ✅ **iOS** → Permisos y configuración nativa
- ✅ **Permisos** → Solicitud automática al usuario

## 🔄 Próximas Mejoras Posibles

1. **Notificaciones por categoría** → Diferentes sonidos/colores
2. **Hora personalizable** → Usuario elige hora de recordatorio
3. **Snooze funcionalidad** → Posponer notificación
4. **Estadísticas** → Cuántas notificaciones cumplidas
5. **Integración con calendario** → Exportar recordatorios

---

## 🚀 Cómo usar

### Para desarrolladores:
```dart
// Programar notificación
await NotificacionesServicio.instance.programarRecordatorioIngreso(
  ingresoId: 'id_del_ingreso',
  monto: 1500000.0,
  descripcion: 'Salario',
  fechaRecordatorio: DateTime.now().add(Duration(days: 30)),
);

// Cancelar notificación
await NotificacionesServicio.instance.cancelarNotificacion('id_del_ingreso');

// Verificar si está activo
bool activas = await NotificacionesServicio.instance.notificacionesActivas();
```

### Para usuarios:
1. Crear ingreso frecuente desde la pantalla de Ingresos
2. Seleccionar frecuencia deseada
3. Configurar notificaciones en Ajustes si es necesario
4. Recibir recordatorios automáticos

¡El sistema está listo para usar! 🎉