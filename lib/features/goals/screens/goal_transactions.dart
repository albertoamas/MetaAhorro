import 'package:flutter/material.dart';
import '../../finance/models/transaction.dart';
import '../../finance/services/finance_service.dart';
import '../models/goal.dart';

class GoalTransactions extends StatelessWidget {
  final Goal goal;

  const GoalTransactions({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FinanceService financeService = FinanceService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transacciones: ${goal.name}'),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: financeService.getTransactionsStream(),
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
              child: Text('No hay transacciones asociadas a esta meta'),
            );
          }

          // Filtrar transacciones por goalId y perfil
          final transactions = snapshot.data!
              .where((transaction) =>
                  transaction.goalId == goal.id && transaction.profile == 'USD') // Cambia 'USD' por el perfil actual
              .toList();

          if (transactions.isEmpty) {
            return const Center(
              child: Text('No hay transacciones asociadas a esta meta'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text('${transaction.amount} ${transaction.currency}'),
                subtitle: Text(transaction.date.toLocal().toString().split(' ')[0]),
                trailing: Text(transaction.category),
              );
            },
          );
        },
      ),
    );
  }
}