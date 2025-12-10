/// AVATAR DE USUARIO
/// Maneja la visualización de la foto de perfil.
/// - Si el usuario tiene foto en Firestore, la carga.
/// - Si está cargando, muestra un spinner.
/// - Si no tiene foto o falla, muestra la inicial del nombre.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'foto_perfil_manager.dart';

class UserAvatar extends StatefulWidget {
  final String nombreUsuario;
  final double size;
  final Key? refreshKey; // Para forzar refresh

  const UserAvatar({
    super.key,
    required this.nombreUsuario,
    this.size = 52,
    this.refreshKey,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _photoURL;
  bool _isLoading = true;
  StreamSubscription? _fotoSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
    
    // Escuchar cambios en la foto de perfil
    _fotoSubscription = FotoPerfilManager().fotoStream.listen((nuevaFoto) {
      if (mounted) {
        setState(() {
          _photoURL = nuevaFoto;
        });
      }
    });
  }

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el refreshKey cambió, recargar la foto
    if (widget.refreshKey != oldWidget.refreshKey) {
      _loadUserPhoto();
    }
  }

  @override
  void dispose() {
    _fotoSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserPhoto() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener foto desde Firestore
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _photoURL = data?['fotoUrl'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _photoURL = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _photoURL = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _photoURL = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildContainer(
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      );
    }
    
    if (_photoURL != null && _photoURL!.isNotEmpty) {
      if (_photoURL!.startsWith('data:image')) {
        // Es una imagen Base64
        final base64String = _photoURL!.split(',')[1];
        final bytes = base64Decode(base64String);
        return _buildContainer(
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: widget.size,
              height: widget.size,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    widget.nombreUsuario.isNotEmpty ? widget.nombreUsuario[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: widget.size * 0.46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // Es una URL de red
        return _buildContainer(
          child: ClipOval(
            child: Image.network(
              _photoURL!,
              fit: BoxFit.cover,
              width: widget.size,
              height: widget.size,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    widget.nombreUsuario.isNotEmpty ? widget.nombreUsuario[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: widget.size * 0.46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return _buildContainer(
      child: Center(
        child: Text(
          widget.nombreUsuario.isNotEmpty ? widget.nombreUsuario[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: widget.size * 0.46,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}