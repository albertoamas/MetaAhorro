import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/navigation/main_navigation.dart';
import 'features/finance/screens/add_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings estén inicializados
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaAhorro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainNavigation(), // Pantalla inicial con BottomNavigationBar
      routes: {
        '/add_transaction': (context) => const AddTransaction(), // Ruta para agregar transacciones
      },
    );
  }
}