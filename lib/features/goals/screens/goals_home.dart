import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goals_service.dart';
import 'progress_history.dart'; // Nueva pantalla para el historial de progreso
import '../widgets/add_progress_form.dart';
import 'add_goal.dart';

class GoalsHome extends StatefulWidget {
  const GoalsHome({Key? key}) : super(key: key);

  @override
  State<GoalsHome> createState() => _GoalsHomeState();
}

class _GoalsHomeState extends State<GoalsHome> {
  final GoalsService _goalsService = GoalsService();
  String _selectedFilter = 'todas'; // Mostrar todas las metas por defecto

  void _showAddProgressDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AddProgressForm(goal: goal),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Ahorro'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value; // Actualizar el filtro seleccionado
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todas',
                child: Text('Todas'),
              ),
              const PopupMenuItem(
                value: 'en_progreso',
                child: Text('En Progreso'),
              ),
              const PopupMenuItem(
                value: 'completadas',
                child: Text('Completadas'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _goalsService.getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay metas disponibles'));
          }

          final goals = snapshot.data!;

          // Filtrar metas según el estado seleccionado
          final filteredGoals = goals.where((goal) {
            if (_selectedFilter == 'completadas') {
              return goal.currentAmount >= goal.targetAmount;
            } else if (_selectedFilter == 'en_progreso') {
              return goal.currentAmount < goal.targetAmount;
            }
            return true; // Mostrar todas las metas si el filtro es "todas"
          }).toList();

          if (filteredGoals.isEmpty) {
            return const Center(child: Text('No hay metas para este filtro'));
          }

          return ListView.builder(
            itemCount: filteredGoals.length,
            itemBuilder: (context, index) {
              final goal = filteredGoals[index];
              final progress = goal.currentAmount / goal.targetAmount;
              final isCompleted = goal.currentAmount >= goal.targetAmount;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isCompleted
                    ? Colors.green[50] // Fondo verde claro para metas completadas
                    : Colors.orange[50], // Fondo naranja claro para metas en progreso
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Nombre de la meta
                          Expanded(
                            child: Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ), // Ícono de "check" para metas completadas
                          if (!isCompleted)
                            const Icon(
                              Icons.timelapse,
                              color: Colors.orange,
                              size: 24,
                            ), // Ícono de "en progreso" para metas en progreso
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progreso de la meta
                      Text(
                        'Progreso: ${goal.currentAmount.toStringAsFixed(2)}/${goal.targetAmount.toStringAsFixed(2)} ${goal.currency}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      // Barra de progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress > 1.0 ? 1.0 : progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botones de acciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProgressHistory(goal: goal),
                                ),
                              );
                            },
                            tooltip: 'Ver Historial de Progreso',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () {
                              _showAddProgressDialog(context, goal);
                            },
                            tooltip: 'Agregar Progreso',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddGoal(goal: goal),
                                ),
                              );
                            },
                            tooltip: 'Editar meta',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Eliminar Meta'),
                                    content: const Text(
                                        '¿Estás seguro de que deseas eliminar esta meta?'),
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
                                await _goalsService.deleteGoal(goal.id);
                              }
                            },
                            tooltip: 'Eliminar meta',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoal()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}