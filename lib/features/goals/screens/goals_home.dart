import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goals_service.dart';
import '../widgets/add_progress_form.dart';
import 'add_goal.dart';

class GoalsHome extends StatefulWidget {
  const GoalsHome({Key? key}) : super(key: key);

  @override
  State<GoalsHome> createState() => _GoalsHomeState();
}

class _GoalsHomeState extends State<GoalsHome> with SingleTickerProviderStateMixin {
  final GoalsService _goalsService = GoalsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Metas de Ahorro',
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
            Tab(text: 'Todas'),
            Tab(text: 'En Progreso'),
            Tab(text: 'Completadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Todas las metas
          _buildAllGoalsTab(),
          
          // Metas en progreso
          _buildFilteredGoalsTab(false),
          
          // Metas completadas
          _buildFilteredGoalsTab(true),
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

  Widget _buildAllGoalsTab() {
    return StreamBuilder<List<Goal>>(
      stream: _goalsService.getGoalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar metas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay metas disponibles'),
          );
        }
        
        final goals = snapshot.data!;
        
        // Separar metas completadas y en progreso
        final completedGoals = goals.where((g) => _isGoalCompleted(g)).toList()
          ..sort((a, b) => b.deadline!.compareTo(a.deadline!));
        
        final activeGoals = goals.where((g) => !_isGoalCompleted(g)).toList()
          ..sort((a, b) => _getProgressPercentage(a).compareTo(_getProgressPercentage(b)));
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de progreso
              _buildProgressOverview(goals),
              
              const SizedBox(height: 24),
              
              // Metas completadas recientemente
              if (completedGoals.isNotEmpty) ...[
                const Text(
                  'Metas Completadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: completedGoals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildSmallGoalCard(
                          completedGoals[index],
                          () => _showGoalDetails(completedGoals[index]),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Metas en progreso
              if (activeGoals.isNotEmpty) ...[
                const Text(
                  'Metas en Progreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeGoals.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGoalCard(
                        activeGoals[index],
                        () => _showGoalDetails(activeGoals[index]),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilteredGoalsTab(bool showCompleted) {
    return StreamBuilder<List<Goal>>(
      stream: _goalsService.getGoalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar metas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay metas disponibles en esta categoría'),
          );
        }
        
        final goals = snapshot.data!;
        
        // Filtrar metas según el estado
        final filteredGoals = goals.where((g) => _isGoalCompleted(g) == showCompleted).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción de la categoría
              _buildCategoryDescription(showCompleted),
              
              const SizedBox(height: 16),
                // Lista de metas
              if (filteredGoals.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredGoals.length,
                  itemBuilder: (context, index) {
                    return _buildGoalCard(
                      filteredGoals[index],
                      () => _showGoalDetails(filteredGoals[index]),
                    );
                  },
                ),
              ] else ...[
                Center(
                  child: Text(
                    showCompleted ? 'No hay metas completadas' : 'No hay metas en progreso',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview(List<Goal> goals) {
    final totalGoals = goals.length;
    final completedCount = goals.where((g) => _isGoalCompleted(g)).length;
    final progress = totalGoals > 0 ? (completedCount / totalGoals) * 100 : 0.0;
    
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
          const Text(
            'Tu progreso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Circular progress indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 6,
                    ),
                    Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completedCount de $totalGoals metas completadas',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${totalGoals - completedCount} metas en progreso',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDescription(bool isCompleted) {
    String title = isCompleted ? 'Metas Completadas' : 'Metas en Progreso';
    String description = isCompleted 
        ? 'Felicitaciones por alcanzar tus objetivos de ahorro.'
        : 'Mantén el enfoque y sigue avanzando hacia tus metas.';
    IconData icon = isCompleted ? Icons.emoji_events : Icons.flag;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3C2FCF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3C2FCF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGoalCard(Goal goal, VoidCallback onTap) {
    bool isCompleted = _isGoalCompleted(goal);
    double progressPercentage = _getProgressPercentage(goal);
    
    return Card(
      elevation: isCompleted ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? const Color(0xFF3C2FCF) : Colors.transparent,
          width: isCompleted ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Goal icon
              Icon(
                isCompleted ? Icons.check_circle : Icons.savings,
                size: 28,
                color: isCompleted 
                    ? Colors.green 
                    : const Color(0xFF3C2FCF),
              ),
              
              const SizedBox(height: 6),
              
              // Title
              Text(
                goal.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Progress or completion indicator
              Text(
                isCompleted 
                    ? '¡Completada!'
                    : '${progressPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted ? Colors.green : const Color(0xFF3C2FCF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, VoidCallback onTap) {
    bool isCompleted = _isGoalCompleted(goal);
    double progressPercentage = _getProgressPercentage(goal);
    
    return Card(
      elevation: isCompleted ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          width: isCompleted ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top part with icon and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Goal icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green.withOpacity(0.1) 
                          : const Color(0xFF3C2FCF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isCompleted ? [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.savings,
                      color: isCompleted ? Colors.green : const Color(0xFF3C2FCF),
                      size: 20,
                    ),
                  ),
                  
                  // Status indicator
                  if (isCompleted)
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 18,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                goal.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.green : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 6),
              
              // Amount progress
              Text(
                '${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} ${goal.currency}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted 
                        ? Colors.green 
                        : const Color(0xFF3C2FCF),
                  ),
                  minHeight: 4,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Progress text and deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${progressPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (goal.deadline != null)
                    Expanded(
                      child: Text(
                        _formatDate(goal.deadline!),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetails(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3C2FCF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isGoalCompleted(goal) ? Icons.check_circle : Icons.savings,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress
                  Text(
                    'Progreso actual: ${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)} ${goal.currency}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  LinearProgressIndicator(
                    value: _getProgressPercentage(goal) / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF3C2FCF),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_getProgressPercentage(goal).toInt()}% completado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Deadline
                  if (goal.deadline != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF3C2FCF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha límite: ${_formatDate(goal.deadline!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Color(0xFF3C2FCF),
                      ),
                    ),
                  ),
                  if (!_isGoalCompleted(goal))
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAddProgressDialog(context, goal);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C2FCF),
                      ),
                      child: const Text(
                        'Agregar Progreso',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  bool _isGoalCompleted(Goal goal) {
    return goal.currentAmount >= goal.targetAmount;
  }

  double _getProgressPercentage(Goal goal) {
    if (goal.targetAmount == 0) return 0;
    return (goal.currentAmount / goal.targetAmount * 100).clamp(0, 100);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}