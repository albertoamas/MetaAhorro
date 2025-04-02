import 'package:flutter/material.dart';
import '../models/goal.dart';

class ProgressHistory extends StatelessWidget {
  final Goal goal;

  const ProgressHistory({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Progreso: ${goal.name}'),
      ),
      body: goal.progressHistory.isEmpty
          ? const Center(
              child: Text('No hay historial de progreso para esta meta'),
            )
          : ListView.builder(
              itemCount: goal.progressHistory.length,
              itemBuilder: (context, index) {
                final progress = goal.progressHistory[index];
                return ListTile(
                  leading: const Icon(Icons.monetization_on, color: Colors.blue),
                  title: Text(
                    '${progress.amount.toStringAsFixed(2)} ${goal.currency}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${progress.date.toLocal()}'.split(' ')[0] +
                        (progress.description != null
                            ? '\n${progress.description}'
                            : ''),
                  ),
                );
              },
            ),
    );
  }
}