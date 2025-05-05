import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goals_service.dart';
import 'progress_history.dart';
import '../widgets/add_progress_form.dart';
import 'add_goal.dart';

class GoalsHome extends StatefulWidget {
  const GoalsHome({Key? key}) : super(key: key);

  @override
  State<GoalsHome> createState() => _GoalsHomeState();
}

class _GoalsHomeState extends State<GoalsHome> {
  final GoalsService _goalsService = GoalsService();
  String _selectedFilter = 'todas';

  // Definir colores personalizados
  final Color _completedColor = const Color.fromARGB(255, 0, 109, 4); // Verde específico requerido
  final Color _inProgressColor = const Color(0xFFEFB700); // Amarillo mostaza

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
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro para coherencia
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C2FCF), // Color morado consistente
        elevation: 0, // Sin sombra
        title: const Text(
          'Metas de Ahorro',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Color blanco para la flecha de regreso
      ),
      body: Column(
        children: [
          // Encabezado con filtros
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3C2FCF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterOption('Todas', 'todas'),
                const SizedBox(width: 8),
                _buildFilterOption('En Progreso', 'en_progreso'),
                const SizedBox(width: 8),
                _buildFilterOption('Completadas', 'completadas'),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: StreamBuilder<List<Goal>>(
              stream: _goalsService.getGoalsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                    color: Color(0xFF3C2FCF),
                  ));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_outlined, 
                          size: 80, 
                          color: const Color(0xFF3C2FCF).withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay metas disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Presiona el botón + para crear una meta',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final goals = snapshot.data!;

                // Filtrar metas según el estado seleccionado
                final filteredGoals = goals.where((goal) {
                  if (_selectedFilter == 'completadas') {
                    return goal.currentAmount >= goal.targetAmount;
                  } else if (_selectedFilter == 'en_progreso') {
                    return goal.currentAmount < goal.targetAmount;
                  }
                  return true;
                }).toList();

                if (filteredGoals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list, 
                          size: 60, 
                          color: const Color(0xFF3C2FCF).withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay metas para el filtro "$_selectedFilter"',
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.grey
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Título de sección con contador
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedFilter == 'todas'
                              ? 'Todas las metas'
                              : _selectedFilter == 'en_progreso'
                                ? 'Metas en progreso'
                                : 'Metas completadas',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3C2FCF),
                            ),
                          ),
                          Text(
                            '${filteredGoals.length} ${filteredGoals.length == 1 ? 'meta' : 'metas'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de metas
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredGoals.length,
                        itemBuilder: (context, index) {
                          final goal = filteredGoals[index];
                          final progress = goal.currentAmount / goal.targetAmount;
                          final isCompleted = goal.currentAmount >= goal.targetAmount;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                // Encabezado de la tarjeta
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isCompleted 
                                        ? _completedColor.withOpacity(0.8) // Verde específico requerido para completadas
                                        : _inProgressColor, // Amarillo mostaza para en progreso
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          goal.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10, 
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          isCompleted ? 'Completada' : 'En progreso',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Contenido de la tarjeta
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Objetivo y moneda
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Objetivo: ${goal.targetAmount.toStringAsFixed(2)} ${goal.currency}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8, 
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              goal.currency,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF3C2FCF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Progreso actual y porcentaje
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Progreso: ${goal.currentAmount.toStringAsFixed(2)} ${goal.currency}',
                                            style: const TextStyle(
                                              fontSize: 14, 
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '${(progress * 100).toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted ? _completedColor : _inProgressColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Barra de progreso
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: progress > 1.0 ? 1.0 : progress,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isCompleted ? _completedColor : _inProgressColor,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Línea divisoria
                                      const Divider(),
                                      
                                      // Botones de acción
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.history,
                                            label: 'Historial',
                                            color: Colors.blue,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProgressHistory(goal: goal),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildActionButton(
                                            icon: Icons.add,
                                            label: 'Progreso',
                                            color: const Color(0xFF3C2FCF),
                                            onPressed: () {
                                              _showAddProgressDialog(context, goal);
                                            },
                                          ),
                                          _buildActionButton(
                                            icon: Icons.edit,
                                            label: 'Editar',
                                            color: Colors.orange,
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddGoal(goal: goal),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildActionButton(
                                            icon: Icons.delete,
                                            label: 'Eliminar',
                                            color: Colors.red,
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
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
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                        ),
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoal()),
          );
        },
        backgroundColor: const Color(0xFF3C2FCF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Meta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}