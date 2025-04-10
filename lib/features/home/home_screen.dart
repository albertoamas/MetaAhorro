import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import '../finance/models/transaction.dart';
import '../finance/services/finance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FinanceService _financeService = FinanceService();

  String _selectedProfile = 'BOB'; // Perfil predeterminado
  double _balance = 0.0;
  List<Transaction> _recentTransactions = [];
  String _userName = 'Usuario'; // Nombre del usuario por defecto

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName(); // Cargar el nombre del usuario
  }

  Future<void> _loadData() async {
    final transactions = await _financeService.getTransactions();
    setState(() {
      // Filtrar transacciones por el perfil seleccionado
      final filteredTransactions = transactions
          .where((transaction) => transaction.currency == _selectedProfile)
          .toList();

      // Calcular el balance total
      _balance = filteredTransactions.fold(
        0.0,
        (sum, transaction) =>
            transaction.type == 'ingreso' ? sum + transaction.amount : sum - transaction.amount,
      );

      // Obtener las últimas 5 transacciones
      _recentTransactions = filteredTransactions.take(5).toList();
    });
  }

  Future<void> _loadUserName() async {
    // Obtener el usuario autenticado desde Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.displayName != null) {
      setState(() {
        _userName = user.displayName!; // Asignar el nombre del usuario
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Espaciado adicional para bajar el contenido
            const SizedBox(height: 32),

            // AppBar Personalizado
            Row(
              children: [
                // Avatar del usuario
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white), // Ícono de usuario como placeholder
                ),
                const SizedBox(width: 12),

                // Nombre del usuario
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 18, // Aumentar el tamaño del texto
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // Icono de notificaciones
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // Acción para notificaciones
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tarjeta de Balance
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF3C2FCF), // Fondo azul violeta
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Elementos decorativos
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -20,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Contenido de la tarjeta
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_balance.toStringAsFixed(2)} $_selectedProfile',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),

                        // Botones para cambiar entre perfiles
                        Row(
                          children: [
                            _buildProfileToggle('BOB'),
                            const SizedBox(width: 8),
                            _buildProfileToggle('USD'),
                            const SizedBox(width: 8),
                            _buildProfileToggle('USDT'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección de Actividades
            const Text(
              'Últimas actividades',
              style: TextStyle(
                fontSize: 20, // Aumentar el tamaño del texto
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C2FCF),
              ),
            ),
            const SizedBox(height: 12),

            // Lista de Actividades
            _recentTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No hay transacciones recientes',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    children: _recentTransactions.map((transaction) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActivityCard(
                          type: transaction.type,
                          title: transaction.category,
                          date:
                              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                          amount:
                              '${transaction.type == 'ingreso' ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // Widget para los botones de perfil
  Widget _buildProfileToggle(String profile) {
    final isSelected = _selectedProfile == profile;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedProfile = profile;
          _loadData(); // Recargar los datos al cambiar de perfil
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(profile),
    );
  }

  // Widget para las tarjetas de actividad
  Widget _buildActivityCard({
    required String type,
    required String title,
    required String date,
    required String amount,
  }) {
    final isIncome = type == 'ingreso';
    return Container(
      padding: const EdgeInsets.all(16), // Aumentar el padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de tipo de transacción
          Container(
            height: 50, // Aumentar el tamaño del ícono
            width: 50,
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16), // Aumentar el espaciado

          // Detalles de la actividad
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Aumentar el tamaño del texto
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14, // Aumentar el tamaño del texto
                ),
              ),
            ],
          ),
          const Spacer(),

          // Monto de la actividad
          Text(
            amount,
            style: TextStyle(
              fontSize: 16, // Aumentar el tamaño del texto
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}