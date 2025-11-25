import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() => _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, bool visible, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).colorScheme.primary),
        onPressed: toggle,
      ),
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      filled: true,
      fillColor: Theme.of(context).cardColor,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario no autenticado'), backgroundColor: Colors.red));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: _currentCtrl.text.trim());
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text.trim());

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Contraseña actualizada'),
            content: const Text('Tu contraseña ha sido actualizada correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al actualizar contraseña.';
      if (e.code == 'wrong-password') msg = 'Contraseña actual incorrecta';
      if (e.code == 'weak-password') msg = 'La nueva contraseña es demasiado débil';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF10B981);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: primaryGreen,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Actualiza tu contraseña de forma segura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _currentCtrl,
                    obscureText: !_showCurrent,
                    decoration: _inputDecoration('Contraseña actual', _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña actual' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: !_showNew,
                    decoration: _inputDecoration('Nueva contraseña', _showNew, () => setState(() => _showNew = !_showNew)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                      if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: !_showConfirm,
                    decoration: _inputDecoration('Confirmar nueva contraseña', _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirma la nueva contraseña';
                      if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Actualizar contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
