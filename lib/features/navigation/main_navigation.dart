import 'package:flutter/material.dart';
import '../finance/screens/finance_home.dart';
import '../goals/screens/goals_home.dart';
import '../home/home_screen.dart';
import '../rewards/screens/rewards_home.dart'; // Importar pantalla de recompensas

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Lista de pantallas actualizada
  final List<Widget> _screens = [
    const HomeScreen(),      // Pantalla de inicio
    const FinanceHome(),     // Resumen Financiero
    const GoalsHome(),       // Metas de Ahorro
    const RewardsHome(),     // Pantalla de Recompensas y Logros
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Mostrar la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambiar la pantalla actual
          });
        },
        selectedItemColor: const Color(0xFF3C2FCF), // Color morado para el ítem seleccionado
        unselectedItemColor: Colors.grey, // Color gris para ítems no seleccionados
        backgroundColor: Colors.white, // Fondo blanco
        elevation: 8, // Elevación para dar sombra
        type: BottomNavigationBarType.fixed, // Tipo fijo para mantener etiquetas visibles
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
        ],
      ),
    );
  }
}