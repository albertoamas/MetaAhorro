import 'package:flutter/material.dart';
import '../finance/screens/finance_home.dart';
import '../goals/screens/goals_home.dart';
import '../home/home_screen.dart'; // Import HomeScreen

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Lista de pantallas
  final List<Widget> _screens = [
    const HomeScreen(),      // Nueva pantalla de inicio
    const FinanceHome(),     // Resumen Financiero
    const GoalsHome(),       // Metas de Ahorro
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
        ],
      ),
    );
  }
}