import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaAhorro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Encabezado con balance
            Container(
              width: 300, // Tamaño fijo
              height: 150, // Tamaño fijo
              margin: const EdgeInsets.symmetric(horizontal: 16.0), // Margen a los lados
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF3232BB), // Azul violeta fuerte
                borderRadius: BorderRadius.circular(16), // Bordes redondeados
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Sombra con opacidad
                    blurRadius: 8,
                    offset: const Offset(0, 4), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Balance Total',
                    style: TextStyle(fontSize: 16, color: Colors.white70), // Tamaño reducido
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_balance.toStringAsFixed(2)} $_selectedProfile',
                    style: const TextStyle(
                      fontSize: 28, // Tamaño reducido
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de perfil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileToggle('BOB'),
                  const SizedBox(width: 8),
                  _buildProfileToggle('USD'),
                  const SizedBox(width: 8),
                  _buildProfileToggle('USDT'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Últimas actividades
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Últimas actividades',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _recentTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay transacciones recientes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _recentTransactions[index];
                            return ListTile(
                              leading: Icon(
                                transaction.type == 'ingreso'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: transaction.type == 'ingreso'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                style: TextStyle(
                                  color: transaction.type == 'ingreso'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(transaction.category),
                              trailing: Text(
                                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ],
              ),
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
        backgroundColor: isSelected ? const Color(0xFF3232BB) : Colors.grey[300], // Azul violeta fuerte
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(profile),
    );
  }
}