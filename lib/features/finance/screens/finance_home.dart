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
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro para coherencia
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C2FCF), // Color morado consistente
        elevation: 0, // Sin sombra
        title: const Text(
          'Resumen Financiero',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Sección de selección de perfil y filtros
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3C2FCF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Selector de perfiles
                _buildProfileSelector(),
                
                // Botón de filtro
                InkWell(
                  onTap: _showFilterDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text('Filtrar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: StreamBuilder<List<Transaction>>(
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
                    // Sección del gráfico
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildPieChart(filteredTransactions),
                    ),
                    
                    // Título de sección
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transacciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          Text(
                            '${filteredTransactions.length} registros',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Lista de transacciones
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay transacciones con los filtros seleccionados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = filteredTransactions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: TransactionCard(
                                    transaction: transaction,
                                    onEdit: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditTransaction(transaction: transaction),
                                        ),
                                      );
                                    },
                                    onDelete: () async {
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF3C2FCF),
                                                ),
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
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
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

  // Widget para selector de perfiles
  Widget _buildProfileSelector() {
    return Row(
      children: [
        _buildProfileToggle('BOB'),
        const SizedBox(width: 8),
        _buildProfileToggle('USD'),
        const SizedBox(width: 8),
        _buildProfileToggle('USDT'),
      ],
    );
  }

  // Widget para botones de perfil
  Widget _buildProfileToggle(String profile) {
    final isSelected = _selectedProfile == profile;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedProfile = profile;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(profile),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Filtrar Transacciones', 
            style: TextStyle(color: Color(0xFF3C2FCF)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por tipo
              DropdownButtonFormField<String?>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos los tipos')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: const TextStyle(color: Color(0xFF3C2FCF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3C2FCF), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filtro por moneda
              DropdownButtonFormField<String?>(
                value: _selectedCurrency,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todas las monedas')),
                  DropdownMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
                  DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                  DropdownMenuItem(value: 'USDT', child: Text('Tether (USDT)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Moneda',
                  labelStyle: const TextStyle(color: Color(0xFF3C2FCF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3C2FCF), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filtro por rango de fechas
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Desde',
                          labelStyle: const TextStyle(color: Color(0xFF3C2FCF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3C2FCF), width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        child: Text(_startDate != null 
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Seleccionar',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hasta',
                          labelStyle: const TextStyle(color: Color(0xFF3C2FCF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3C2FCF), width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        child: Text(_endDate != null 
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Seleccionar',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Limpiar filtros
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _selectedCurrency = null;
                    _startDate = null;
                    _endDate = null;
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar filtros'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C2FCF),
              ),
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
            Text(
              'Balance: $_selectedProfile',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C2FCF),
              ),
            ),
            const SizedBox(height: 16),
            hasData
                ? SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        // Gráfico
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: ingresos,
                                  color: Colors.green,
                                  radius: 25,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: gastos,
                                  color: Colors.red,
                                  radius: 25,
                                  showTitle: false,
                                ),
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
                        
                        // Leyenda con valores
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItemWithAmount('Ingresos', Colors.green, ingresos),
                              const SizedBox(height: 12),
                              _buildLegendItemWithAmount('Gastos', Colors.red, gastos),
                              const SizedBox(height: 12),
                              _buildLegendItemWithAmount('Ahorros', Colors.blue, ahorros),
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
                        'No hay datos disponibles para mostrar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItemWithAmount(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}