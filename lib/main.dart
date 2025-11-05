
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const WalletFlowApp());
}

/// Aplicación principal de Wallet Flow
class WalletFlowApp extends StatelessWidget {
  const WalletFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Configuración del tema principal con colores verdes
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF10B981),
        fontFamily: 'SF Pro Text', // Fuente moderna (opcional)
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Configuración del tema de inputs
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xFF065F46),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        
        // Configuración del tema de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
