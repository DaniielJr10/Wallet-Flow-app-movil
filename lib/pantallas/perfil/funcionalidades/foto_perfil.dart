/// COMPONENTE VISUAL DE FOTO
/// Muestra la imagen del usuario en un contenedor circular estilizado.
/// Si está en modo edición, superpone un botón flotante para cambiar la foto.
/// Maneja la carga de imágenes de red con un fallback a un icono por defecto.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'utils_perfil.dart';

class FotoPerfil extends StatelessWidget {
  final String? urlFoto;
  final bool modoEdicion;
  final VoidCallback onCambiarFoto;
  final Animation<double> scaleAnimation;
  final String nombreUsuario;

  const FotoPerfil({
    super.key,
    required this.urlFoto,
    required this.modoEdicion,
    required this.onCambiarFoto,
    required this.scaleAnimation,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Center(
        child: GestureDetector(
          onTap: onCambiarFoto,
          child: Stack(
            children: [
            // Foto de perfil
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: UtilsPerfil.colorPrincipal,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: UtilsPerfil.colorPrincipal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(56),
                child: urlFoto != null
                    ? _buildImageWidget()
                    : _buildAvatarPorDefecto(),
              ),
            ),
            
            // Botón para cambiar foto (siempre visible)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onCambiarFoto,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UtilsPerfil.colorPrincipal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (urlFoto!.startsWith('data:image')) {
      // Es una imagen Base64
      final base64String = urlFoto!.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarPorDefecto();
        },
      );
    } else {
      // Es una URL de red
      return Image.network(
        urlFoto!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarPorDefecto();
        },
      );
    }
  }

  Widget _buildAvatarPorDefecto() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UtilsPerfil.colorPrincipal,
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(56),
      ),
      child: Center(
        child: Text(
          nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}