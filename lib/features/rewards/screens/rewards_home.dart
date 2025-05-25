import 'package:flutter/material.dart';
import '../models/reward.dart';
import '../models/reward_history.dart';
import '../services/rewards_service.dart';
import '../widgets/reward_card.dart';

class RewardsHome extends StatefulWidget {
  const RewardsHome({Key? key}) : super(key: key);

  @override
  State<RewardsHome> createState() => _RewardsHomeState();
}

class _RewardsHomeState extends State<RewardsHome> with SingleTickerProviderStateMixin {
  final RewardsService _rewardsService = RewardsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Inicializar las recompensas por defecto para el usuario
    _rewardsService.initializeUserRewards();
    // Actualizar la racha de login
    _rewardsService.updateUserLoginStreak();
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
          'Mis Logros',
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
            Tab(text: 'Todos'),
            Tab(text: 'Ahorros'),
            Tab(text: 'Metas'),
            Tab(text: 'Gastos'),
            Tab(text: 'Rachas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Todos los logros
          _buildAllRewardsTab(),
          
          // Logros de ahorros
          _buildCategoryRewardsTab(RewardCategory.savings),
          
          // Logros de metas
          _buildCategoryRewardsTab(RewardCategory.goals),
          
          // Logros de gastos
          _buildCategoryRewardsTab(RewardCategory.expenses),
          
          // Logros de rachas
          _buildCategoryRewardsTab(RewardCategory.streak),
        ],
      ),
    );
  }

  Widget _buildAllRewardsTab() {
    return StreamBuilder<List<Reward>>(
      stream: _rewardsService.getRewardsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar logros: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay logros disponibles'),
          );
        }
        
        final rewards = snapshot.data!;
        
        // Separar recompensas desbloqueadas y bloqueadas
        final unlockedRewards = rewards.where((r) => r.isUnlocked).toList()
          ..sort((a, b) => b.unlockDate!.compareTo(a.unlockDate!));
        
        final lockedRewards = rewards.where((r) => !r.isUnlocked).toList()
          ..sort((a, b) => a.level.compareTo(b.level));
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de progreso
              _buildProgressOverview(rewards),
              
              const SizedBox(height: 24),
              
              // Logros desbloqueados recientemente
              if (unlockedRewards.isNotEmpty) ...[
                const Text(
                  'Logros Desbloqueados',
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
                    itemCount: unlockedRewards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SmallRewardCard(
                          reward: unlockedRewards[index],
                          onTap: () => _showRewardDetails(unlockedRewards[index]),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Logros por desbloquear
              if (lockedRewards.isNotEmpty) ...[
                const Text(
                  'Logros por Desbloquear',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lockedRewards.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RewardCard(
                        reward: lockedRewards[index],
                        onTap: () => _showRewardDetails(lockedRewards[index]),
                      ),
                    );
                  },
                ),
              ],
              
              // Historial de logros
              const SizedBox(height: 20),
              _buildRewardHistory(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRewardsTab(RewardCategory category) {
    return StreamBuilder<List<Reward>>(
      stream: _rewardsService.getRewardsByCategoryStream(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar logros: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay logros disponibles en esta categoría'),
          );
        }
        
        final rewards = snapshot.data!;
        
        // Separar recompensas desbloqueadas y bloqueadas
        final unlockedRewards = rewards.where((r) => r.isUnlocked).toList();
        final lockedRewards = rewards.where((r) => !r.isUnlocked).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción de la categoría
              _buildCategoryDescription(category),
              
              const SizedBox(height: 16),
              
              // Logros desbloqueados
              if (unlockedRewards.isNotEmpty) ...[
                const Text(
                  'Desbloqueados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: unlockedRewards.length,
                  itemBuilder: (context, index) {
                    return RewardCard(
                      reward: unlockedRewards[index],
                      onTap: () => _showRewardDetails(unlockedRewards[index]),
                      showProgress: false,
                    );
                  },
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Logros por desbloquear
              if (lockedRewards.isNotEmpty) ...[
                const Text(
                  'Por Desbloquear',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lockedRewards.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RewardCard(
                        reward: lockedRewards[index],
                        onTap: () => _showRewardDetails(lockedRewards[index]),
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

  Widget _buildProgressOverview(List<Reward> rewards) {
    final totalRewards = rewards.length;
    final unlockedCount = rewards.where((r) => r.isUnlocked).length;
    final progress = totalRewards > 0 ? (unlockedCount / totalRewards) * 100 : 0.0;
    
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
                    '$unlockedCount de $totalRewards logros desbloqueados',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${totalRewards - unlockedCount} logros por desbloquear',
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

  Widget _buildRewardHistory() {
    return StreamBuilder<List<RewardHistory>>(
      stream: _rewardsService.getRewardHistoryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final history = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Logros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length > 5 ? 5 : history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF3C2FCF),
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    item.rewardTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item.triggerAction,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    _formatDate(item.unlockDate),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryDescription(RewardCategory category) {
    String title;
    String description;
    IconData icon;
    
    switch (category) {
      case RewardCategory.savings:
        title = 'Logros de Ahorro';
        description = 'Premios por alcanzar metas de ahorro y ser constante en el proceso.';
        icon = Icons.savings;
        break;
      case RewardCategory.expenses:
        title = 'Control de Gastos';
        description = 'Reconocimientos por mantener un seguimiento constante de tus gastos.';
        icon = Icons.account_balance_wallet;
        break;
      case RewardCategory.goals:
        title = 'Cumplimiento de Metas';
        description = 'Logros por alcanzar tus metas financieras establecidas.';
        icon = Icons.flag;
        break;
      case RewardCategory.streak:
        title = 'Constancia';
        description = 'Premios por usar la aplicación de forma consistente.';
        icon = Icons.calendar_today;
        break;
      case RewardCategory.special:
        title = 'Logros Especiales';
        description = 'Reconocimientos especiales por acciones destacadas.';
        icon = Icons.star;
        break;
    }
    
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

  void _showRewardDetails(Reward reward) {
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
                    _getIconForReward(reward),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reward.title,
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
                  // Descripción
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Criterio
                  if (reward.criteria != null) ...[
                    const Text(
                      'Cómo conseguirlo:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C2FCF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.criteria!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Progreso
                  if (!reward.isUnlocked) ...[
                    const Text(
                      'Progreso actual:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: reward.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3C2FCF),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reward.progress.toInt()}% completado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  
                  // Fecha de desbloqueo
                  if (reward.isUnlocked && reward.unlockDate != null) ...[
                    const Text(
                      'Desbloqueado:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C2FCF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(reward.unlockDate!),
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
                mainAxisAlignment: MainAxisAlignment.end,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForReward(Reward reward) {
    switch (reward.type) {
      case RewardType.badge:
        return Icons.military_tech;
      case RewardType.achievement:
        return Icons.emoji_events;
      case RewardType.milestone:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}