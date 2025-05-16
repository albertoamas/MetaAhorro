import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../finance/models/transaction.dart';
import '../finance/services/finance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FinanceService _financeService = FinanceService();

  String _selectedProfile = 'BOB';
  double _balance = 0.0;
  List<Transaction> _recentTransactions = [];
  String _userName = 'Usuario';
  
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final transactions = await _financeService.getTransactions();
      
      final filteredTransactions = transactions
          .where((transaction) => transaction.currency == _selectedProfile)
          .toList();

      filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

      double balance = 0.0;
      double monthlyIncome = 0.0;
      double monthlyExpense = 0.0;

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      for (var transaction in filteredTransactions) {
        if (transaction.type == 'ingreso') {
          balance += transaction.amount;
          if (transaction.date.isAfter(firstDayOfMonth)) {
            monthlyIncome += transaction.amount;
          }
        } else if (transaction.type == 'gasto') {
          balance -= transaction.amount;
          if (transaction.date.isAfter(firstDayOfMonth)) {
            monthlyExpense += transaction.amount;
          }
        }
      }

      setState(() {
        _balance = balance;
        _monthlyIncome = monthlyIncome;
        _monthlyExpense = monthlyExpense;
        _recentTransactions = filteredTransactions.take(5).toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error al cargar los datos: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.displayName != null) {
      setState(() {
        _userName = user.displayName!;
      });
    }
  }

  Future<void> _signOut() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C2FCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmed) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3C2FCF),
              ),
            );
          },
        );

        await FirebaseAuth.instance.signOut();
        
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Has cerrado sesión exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Mi Perfil",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3C2FCF),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF3C2FCF),
                radius: 40,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF3C2FCF),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Nombre:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _userName,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: Color(0xFF3C2FCF),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Email:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            FirebaseAuth.instance.currentUser?.email ?? 'No disponible',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cerrar",
                style: TextStyle(color: Color(0xFF3C2FCF)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3C2FCF),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF3C2FCF),
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: const Color(0xFF3C2FCF),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              '¡Hola, $_userName!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Bienvenido a MetaAhorro',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        children: [
                          Container(
                            color: const Color(0xFF3C2FCF),
                          ),
                          Positioned(
                            top: -40,
                            right: -30,
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            left: -20,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'perfil':
                              _showProfileDialog();
                              break;
                            case 'ajustes':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ajustes - Funcionalidad en desarrollo')),
                              );
                              break;
                            case 'tema':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cambiar tema - Funcionalidad en desarrollo')),
                              );
                              break;
                            case 'ayuda':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ayuda y soporte - Funcionalidad en desarrollo')),
                              );
                              break;
                            case 'cerrar_sesion':
                              _signOut();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'perfil',
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Color(0xFF3C2FCF)),
                                SizedBox(width: 10),
                                Text('Mi Perfil'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'ajustes',
                            child: Row(
                              children: [
                                Icon(Icons.settings, color: Color(0xFF3C2FCF)),
                                SizedBox(width: 10),
                                Text('Ajustes'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'tema',
                            child: Row(
                              children: [
                                Icon(Icons.color_lens, color: Color(0xFF3C2FCF)),
                                SizedBox(width: 10),
                                Text('Cambiar Tema'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'ayuda',
                            child: Row(
                              children: [
                                Icon(Icons.help_outline, color: Color(0xFF3C2FCF)),
                                SizedBox(width: 10),
                                Text('Ayuda y Soporte'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'cerrar_sesion',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 24),
                          _buildMonthlyStatsCard(),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Últimas actividades',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3C2FCF),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Ver todo',
                                  style: TextStyle(
                                    color: Color(0xFF3C2FCF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _recentTransactions.isEmpty
                              ? SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No hay transacciones recientes',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentTransactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = _recentTransactions[index];
                                    return _buildActivityCard(
                                      type: transaction.type,
                                      title: transaction.category,
                                      subtitle: transaction.description ?? 'Sin descripción',
                                      date:
                                          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                      amount:
                                          '${transaction.type == 'ingreso' ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3C2FCF), Color(0xFF6A60FD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C2FCF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 6),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            Text(
              '${_balance.toStringAsFixed(2)} $_selectedProfile',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileToggle('BOB'),
                _buildProfileToggle('USD'),
                _buildProfileToggle('USDT'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Este mes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                  title: 'Ingresos',
                  value: '${_monthlyIncome.toStringAsFixed(2)} $_selectedProfile',
                  valueColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                  title: 'Gastos',
                  value: '${_monthlyExpense.toStringAsFixed(2)} $_selectedProfile',
                  valueColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileToggle(String profile) {
    final isSelected = _selectedProfile == profile;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedProfile = profile;
          _loadData();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.white,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(profile),
    );
  }

  Widget _buildActivityCard({
    required String type,
    required String title,
    required String subtitle,
    required String date,
    required String amount,
  }) {
    final isIncome = type == 'ingreso';
    final isExpense = type == 'gasto';
    final isSaving = type == 'ahorro';
    
    Color iconColor;
    IconData iconData;
    
    if (isIncome) {
      iconColor = Colors.green;
      iconData = Icons.arrow_downward;
    } else if (isExpense) {
      iconColor = Colors.red;
      iconData = Icons.arrow_upward;
    } else {
      iconColor = Colors.blue;
      iconData = Icons.savings;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}