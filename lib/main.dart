import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/navigation/main_navigation.dart';
import 'features/finance/screens/add_transaction.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings estén inicializados
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaAhorro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF3C2FCF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C2FCF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3C2FCF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), // Pantalla inicial de Splash
      routes: {
        '/login': (context) => const LoginScreen(), // Ruta para login
        '/main_navigation': (context) => const MainNavigation(), // Ruta para la navegación principal
        '/add_transaction': (context) => const AddTransaction(), // Ruta para agregar transacciones
      },
    );
  }
}