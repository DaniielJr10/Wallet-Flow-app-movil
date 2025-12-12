
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase/firebase_options.dart';
import 'firebase/servicios/NotificacionesService/notificaciones_servicio.dart';
import 'pantallas/ahorros/funcionalidades/notificaciones/servicio_notificaciones_ahorros.dart';
import 'auth_wrapper.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar servicio de notificaciones
  try {
    final notificacionesInicializadas = await NotificacionesServicio.instance.inicializar();
    if (notificacionesInicializadas) {
      print('✅ Servicio de notificaciones inicializado correctamente');
      await NotificacionesServicio.instance.verificarPermisos();
    } else {
      print('⚠️ No se pudo inicializar el servicio de notificaciones');
    }
  } catch (e) {
    print('❌ Error inicializando notificaciones: $e');
  }
  
  // Inicializar servicio de notificaciones de ahorros
  try {
    final ahorrosNotificacionesInicializadas = await ServicioNotificacionesAhorros.instance.inicializar();
    if (ahorrosNotificacionesInicializadas) {
      print('✅ Servicio de notificaciones de ahorros inicializado correctamente');
    } else {
      print('⚠️ No se pudo inicializar el servicio de notificaciones de ahorros');
    }
  } catch (e) {
    print('❌ Error inicializando notificaciones de ahorros: $e');
  }
  
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
      
      // Configuración de localización en español
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      
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
