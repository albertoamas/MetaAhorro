import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Para gráficos
import '../models/transaction.dart';
import '../services/finance_service.dart';
import '../widgets/transaction_card.dart';
import 'edit_transaction.dart';

class FinanceHome extends StatefulWidget {
  const FinanceHome({Key? key}) : super(key: key);

  @override
  State<FinanceHome> createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome> {
  final FinanceService _financeService = FinanceService();

  // Filtros
  String? _selectedType;
  String? _selectedCurrency;
  DateTime? _startDate;
  DateTime? _endDate;

  // Perfil seleccionado
  String _selectedProfile = 'USD'; // Valor predeterminado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedProfile = value; // Cambiar el perfil seleccionado
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'USD', child: Text('Dólares (USD)')),
              const PopupMenuItem(value: 'USDT', child: Text('Tether (USDT)')),
              const PopupMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
            ],
            icon: const Icon(Icons.account_balance_wallet),
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _financeService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay transacciones disponibles'),
            );
          }

          final transactions = snapshot.data!;

          // Filtrar transacciones por perfil y otros filtros
          final filteredTransactions = transactions.where((transaction) {
            final matchesProfile = transaction.profile == _selectedProfile;
            final matchesType = _selectedType == null || transaction.type == _selectedType;
            final matchesCurrency = _selectedCurrency == null || transaction.currency == _selectedCurrency;
            final matchesStartDate = _startDate == null || transaction.date.isAfter(_startDate!);
            final matchesEndDate = _endDate == null || transaction.date.isBefore(_endDate!);
            return matchesProfile && matchesType && matchesCurrency && matchesStartDate && matchesEndDate;
          }).toList();

          return Column(
            children: [
              // Gráfico Circular
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPieChart(filteredTransactions),
              ),
              // Lista de transacciones
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onEdit: () async {
                        // Navegar a la pantalla de edición
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTransaction(transaction: transaction),
                          ),
                        );
                      },
                      onDelete: () async {
                        // Confirmar eliminación
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Eliminar Transacción'),
                              content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await _financeService.deleteTransaction(transaction.id);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Transacciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por tipo
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 16),

              // Filtro por moneda
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                items: const [
                  DropdownMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
                  DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                  DropdownMenuItem(value: 'USDT', child: Text('Tether (USDT)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Moneda'),
              ),
              const SizedBox(height: 16),

              // Filtro por rango de fechas
              ListTile(
                title: const Text('Fecha de inicio'),
                subtitle: Text(_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'No seleccionada'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Fecha de fin'),
                subtitle: Text(_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'No seleccionada'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(List<Transaction> transactions) {
    final double ingresos = transactions
        .where((transaction) => transaction.type == 'ingreso')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final double gastos = transactions
        .where((transaction) => transaction.type == 'gasto')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final double ahorros = transactions
        .where((transaction) => transaction.type == 'ahorro')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: ingresos,
                      color: Colors.green,
                      radius: 10,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: gastos,
                      color: Colors.red,
                      radius: 10,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: ahorros,
                      color: Colors.blue,
                      radius: 10,
                      showTitle: false,
                    ),
                  ],
                  sectionsSpace: 2,
                ),
              ),
              Center(
                child: Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Ingresos', Colors.green),
            _buildLegendItem('Gastos', Colors.red),
            _buildLegendItem('Ahorros', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}