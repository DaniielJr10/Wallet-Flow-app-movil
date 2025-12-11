import 'dart:async';

/// Gestor global para cambios de nombre de usuario.
class NombreUsuarioManager {
  static final NombreUsuarioManager _instance = NombreUsuarioManager._internal();
  factory NombreUsuarioManager() => _instance;
  NombreUsuarioManager._internal();

  final StreamController<String> _controller = StreamController<String>.broadcast();

  Stream<String> get nombreStream => _controller.stream;

  void notificarCambioNombre(String nuevoNombre) {
    _controller.add(nuevoNombre);
  }
}
