import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewTransactions; // Nuevo parámetro

  const GoalCard({
    Key? key,
    required this.goal,
    this.onEdit,
    this.onDelete,
    this.onViewTransactions, // Inicializar el nuevo parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Progreso: ${goal.currentAmount}/${goal.targetAmount} ${goal.currency}'),
            if (goal.deadline != null)
              Text('Fecha límite: ${goal.deadline!.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewTransactions != null)
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: onViewTransactions, // Acción para ver transacciones
                    tooltip: 'Ver transacciones',
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit, // Acción para editar
                    tooltip: 'Editar meta',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete, // Acción para eliminar
                    tooltip: 'Eliminar meta',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}