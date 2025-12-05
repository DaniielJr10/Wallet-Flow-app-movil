/// MODELO DE DATOS PARA NOTAS
/// Define la estructura de datos que se almacenará en Firestore
/// como subcolección de usuarios.

class NotaModelo {
  final String? id;
  final String texto;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final List<String> etiquetas;
  final String color;
  final bool esImportante;
  final String? categoria;

  const NotaModelo({
    this.id,
    required this.texto,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.etiquetas = const [],
    this.color = '#FFE082', // Amarillo por defecto
    this.esImportante = false,
    this.categoria,
  });

  /// Constructor para crear desde datos de Firestore
  factory NotaModelo.fromFirestore(Map<String, dynamic> data, String documentId) {
    return NotaModelo(
      id: documentId,
      texto: data['texto'] ?? '',
      fechaCreacion: DateTime.parse(data['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: DateTime.parse(data['fechaActualizacion'] ?? DateTime.now().toIso8601String()),
      etiquetas: List<String>.from(data['etiquetas'] ?? []),
      color: data['color'] ?? '#FFE082',
      esImportante: data['esImportante'] ?? false,
      categoria: data['categoria'],
    );
  }

  /// Constructor para crear desde datos locales (migración)
  factory NotaModelo.fromLocal(Map<String, dynamic> data) {
    return NotaModelo(
      texto: data['text'] ?? data['texto'] ?? '',
      fechaCreacion: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      fechaActualizacion: DateTime.now(),
      etiquetas: List<String>.from(data['tags'] ?? data['etiquetas'] ?? []),
      color: data['color'] ?? '#FFE082',
      esImportante: data['esImportante'] ?? false,
      categoria: data['categoria'],
    );
  }

  /// Convierte a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'texto': texto,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
      'etiquetas': etiquetas,
    };

    // No enviar campos innecesarios
    if (color != '#FFE082') {
      map['color'] = color;
    }
    if (esImportante) {
      map['esImportante'] = esImportante;
    }
    if (categoria != null) {
      map['categoria'] = categoria;
    }

    return map;
  }

  /// Convierte a Map para compatibilidad local
  Map<String, dynamic> toLocal() {
    return {
      'id': id,
      'text': texto,
      'date': fechaCreacion.toIso8601String(),
      'tags': etiquetas,
      'color': color,
      'esImportante': esImportante,
      'categoria': categoria,
    };
  }

  /// Crear copia con campos modificados
  NotaModelo copyWith({
    String? id,
    String? texto,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<String>? etiquetas,
    String? color,
    bool? esImportante,
    String? categoria,
  }) {
    return NotaModelo(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      etiquetas: etiquetas ?? this.etiquetas,
      color: color ?? this.color,
      esImportante: esImportante ?? this.esImportante,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotaModelo && 
           other.id == id &&
           other.texto == texto;
  }

  @override
  int get hashCode => id.hashCode ^ texto.hashCode;

  @override
  String toString() {
    return 'NotaModelo{id: $id, texto: ${texto.substring(0, texto.length > 20 ? 20 : texto.length)}..., fechaCreacion: $fechaCreacion}';
  }
}
