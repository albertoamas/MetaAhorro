import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../services/finance_service.dart';
import 'edit_transaction.dart';

class FinanceHome extends StatefulWidget {
  const FinanceHome({Key? key}) : super(key: key);

  @override
  State<FinanceHome> createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome> with SingleTickerProviderStateMixin {
  final FinanceService _financeService = FinanceService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resumen Financiero',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'BOB'),
            Tab(text: 'USD'),
            Tab(text: 'USDT'),
          ],
        ),
      ),      body: TabBarView(
        controller: _tabController,
        children: [
          // Resumen general
          _buildOverviewTab(),
          
          // Bolivianos (BOB)
          _buildCurrencyTab('BOB'),
          
          // Dólares (USD)
          _buildCurrencyTab('USD'),
          
          // Tether (USDT)
          _buildCurrencyTab('USDT'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_transaction');
        },
        backgroundColor: const Color(0xFF3C2FCF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Widget _buildOverviewTab() {
    return StreamBuilder<List<Transaction>>(
      stream: _financeService.getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar transacciones: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, 
                     size: 80, color: Color(0xFF3C2FCF)),
                SizedBox(height: 16),
                Text('No hay transacciones disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text('Presiona el botón + para agregar una transacción',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        final transactions = snapshot.data!;
          return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen por monedas
              _buildCurrencyBreakdown(transactions),
              
              const SizedBox(height: 24),
              
              // Transacciones recientes
              const Text(
                'Transacciones Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildRecentTransactions(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyTab(String currency) {
    return StreamBuilder<List<Transaction>>(
      stream: _financeService.getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar transacciones: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, 
                     size: 80, color: Color(0xFF3C2FCF)),
                SizedBox(height: 16),
                Text('No hay transacciones en $currency',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        final transactions = snapshot.data!;
        final currencyTransactions = transactions
            .where((t) => t.currency == currency)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        
        if (currencyTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, 
                     size: 80, color: Color(0xFF3C2FCF)),
                SizedBox(height: 16),
                Text('No hay transacciones en $currency',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance específico de la moneda
              _buildCurrencyBalance(currencyTransactions, currency),
              
              const SizedBox(height: 24),
              
              // Gráfico específico
              _buildCurrencyChart(currencyTransactions),
              
              const SizedBox(height: 24),
              
              // Lista de transacciones
              Text(
                'Transacciones en $currency',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currencyTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = currencyTransactions[index];
                  return _buildTransactionTile(transaction);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCurrencyBreakdown(List<Transaction> transactions) {
    final currencies = ['BOB', 'USD', 'USDT'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen por Moneda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        ...currencies.map((currency) {
          final currencyTransactions = transactions.where((t) => t.currency == currency).toList();
          final total = currencyTransactions.fold(0.0, (sum, t) => 
            t.type == 'ingreso' ? sum + t.amount : sum - t.amount);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3C2FCF).withOpacity(0.1),
                child: Text(
                  currency,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C2FCF),
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                currency,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${currencyTransactions.length} transacciones'),
              trailing: Text(
                total.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: total >= 0 ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    final recentTransactions = transactions
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final limitedTransactions = recentTransactions.take(5).toList();
    
    if (limitedTransactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay transacciones recientes',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      children: limitedTransactions.map((transaction) {
        return _buildTransactionTile(transaction);
      }).toList(),
    );
  }

  Widget _buildCurrencyBalance(List<Transaction> transactions, String currency) {
    final double ingresos = transactions
        .where((t) => t.type == 'ingreso')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final double gastos = transactions
        .where((t) => t.type == 'gasto')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final double ahorros = transactions
        .where((t) => t.type == 'ahorro')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final double balance = ingresos - gastos;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3C2FCF), Color(0xFF4A3AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance en $currency',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            balance.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: balance >= 0 ? Colors.white : Colors.red.shade200,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem('Ingresos', ingresos, Colors.green.shade200),
              _buildBalanceItem('Gastos', gastos, Colors.red.shade200),
              _buildBalanceItem('Ahorros', ahorros, Colors.blue.shade200),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildBalanceItem(String label, double amount, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyChart(List<Transaction> transactions) {
    final double ingresos = transactions
        .where((t) => t.type == 'ingreso')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final double gastos = transactions
        .where((t) => t.type == 'gasto')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final double ahorros = transactions
        .where((t) => t.type == 'ahorro')
        .fold(0.0, (sum, t) => sum + t.amount);
        
    final bool hasData = ingresos > 0 || gastos > 0 || ahorros > 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Distribución por Tipo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            hasData
                ? SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (ingresos > 0)
                                  PieChartSectionData(
                                    value: ingresos,
                                    color: Colors.green,
                                    radius: 25,
                                    showTitle: false,
                                  ),
                                if (gastos > 0)
                                  PieChartSectionData(
                                    value: gastos,
                                    color: Colors.red,
                                    radius: 25,
                                    showTitle: false,
                                  ),
                                if (ahorros > 0)
                                  PieChartSectionData(
                                    value: ahorros,
                                    color: Colors.blue,
                                    radius: 25,
                                    showTitle: false,
                                  ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ingresos > 0)
                                _buildLegendItem('Ingresos', Colors.green, ingresos),
                              const SizedBox(height: 8),
                              if (gastos > 0)
                                _buildLegendItem('Gastos', Colors.red, gastos),
                              const SizedBox(height: 8),
                              if (ahorros > 0)
                                _buildLegendItem('Ahorros', Colors.blue, ahorros),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  Widget _buildTransactionTile(Transaction transaction) {
    Color typeColor;
    IconData typeIcon;
    
    switch (transaction.type) {
      case 'ingreso':
        typeColor = Colors.green;
        typeIcon = Icons.arrow_upward;
        break;
      case 'gasto':
        typeColor = Colors.red;
        typeIcon = Icons.arrow_downward;
        break;
      case 'ahorro':
        typeColor = Colors.blue;
        typeIcon = Icons.savings;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showTransactionActions(transaction),
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${transaction.type}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == 'gasto' ? '-' : '+'}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: typeColor,
                fontSize: 14,
              ),
            ),
            Text(
              transaction.currency,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionActions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de barra superior
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Título
                Text(
                  'Opciones de Transacción',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Información de la transacción
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.type.toUpperCase()} • ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botones de acción
                Row(
                  children: [
                    // Botón Editar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editTransaction(transaction);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C2FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Botón Eliminar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteTransaction(transaction);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransaction(transaction: transaction),
      ),
    );
    
    // Si se editó correctamente, el stream se actualizará automáticamente
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción editada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Eliminar Transacción',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performDeleteTransaction(transaction);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteTransaction(Transaction transaction) async {
    try {
      await _financeService.deleteTransaction(transaction.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}