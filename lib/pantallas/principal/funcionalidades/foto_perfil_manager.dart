/// GESTOR DE FOTO DE PERFIL
/// Maneja la sincronización de la foto de perfil entre diferentes pantallas
/// usando un Stream global.
import 'dart:async';

class FotoPerfilManager {
  static final FotoPerfilManager _instance = FotoPerfilManager._internal();
  factory FotoPerfilManager() => _instance;
  FotoPerfilManager._internal();

  final StreamController<String?> _fotoController = StreamController<String?>.broadcast();

  /// Stream para escuchar cambios en la foto de perfil
  Stream<String?> get fotoStream => _fotoController.stream;

  /// Notificar que la foto cambió
  void notificarCambioFoto(String? nuevaFotoUrl) {
    _fotoController.add(nuevaFotoUrl);
  }

  /// Limpiar recursos
  void dispose() {
    _fotoController.close();
  }
}
