import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward.dart';
import '../models/reward_history.dart';
import '../../goals/models/goal.dart';
import '../../finance/models/transaction.dart' as finance;

class RewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener todas las recompensas del usuario actual
  Stream<List<Reward>> getRewardsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => Reward.fromFirestore(doc))
          .toList();
      });
  }

  // Obtener recompensas desbloqueadas
  Stream<List<Reward>> getUnlockedRewardsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .where('isUnlocked', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => Reward.fromFirestore(doc))
          .toList();
      });
  }

  // Obtener recompensas por categoría
  Stream<List<Reward>> getRewardsByCategoryStream(RewardCategory category) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    
    String categoryString = category.toString().split('.').last;

    return _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .where('category', isEqualTo: categoryString)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => Reward.fromFirestore(doc))
          .toList();
      });
  }

  // Obtener historial de recompensas
  Stream<List<RewardHistory>> getRewardHistoryStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
      .collection('users')
      .doc(userId)
      .collection('rewardHistory')
      .orderBy('unlockDate', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => RewardHistory.fromFirestore(doc))
          .toList();
      });
  }

  // Verificar y actualizar progreso de recompensas basado en una meta cumplida
  Future<void> checkAndUpdateGoalBasedRewards(Goal goal) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Verificar si la meta está cumplida (100% o más)
    double progressPercentage = (goal.currentAmount / goal.targetAmount) * 100;
    bool isGoalCompleted = progressPercentage >= 100;

    // Obtener todas las recompensas relacionadas con metas
    final rewardsSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .where('category', isEqualTo: 'goals')
      .get();

    for (var doc in rewardsSnapshot.docs) {
      final reward = Reward.fromFirestore(doc);
      
      // Si ya está desbloqueada, continuar con la siguiente
      if (reward.isUnlocked) continue;
      
      // Actualizar progreso basado en el tipo de recompensa
      switch (reward.type) {
        case RewardType.milestone:
          // Verificar si es un logro por completar cierto número de metas
          if (reward.metadata != null && 
              reward.metadata!.containsKey('goalsCount')) {            // Obtener cuántas metas se han completado
            final completedGoalsSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('goals')
              .where('isCompleted', isEqualTo: true)
              .get();
            
            int completedGoalsCount = completedGoalsSnapshot.docs.length;
            int requiredGoals = reward.metadata!['goalsCount'];
            
            double progress = (completedGoalsCount / requiredGoals) * 100;
            bool shouldUnlock = completedGoalsCount >= requiredGoals;
            
            // Actualizar el progreso o desbloquear
            await _updateRewardProgress(
              reward.id,
              progress,
              shouldUnlock,
              'Completar $completedGoalsCount metas de ahorro',
            );
          }
          break;
        
        case RewardType.achievement:
          // Si la meta se completó y este es un logro por completar una meta específica
          if (isGoalCompleted && 
              reward.metadata != null &&
              reward.metadata!.containsKey('targetAmountThreshold')) {
            // Verificar si la meta cumple el criterio de monto mínimo
            double threshold = reward.metadata!['targetAmountThreshold'];
            if (goal.targetAmount >= threshold) {
              await _updateRewardProgress(
                reward.id,
                100,
                true,
                'Completar una meta de ${goal.targetAmount} ${goal.currency}',
              );
            }
          }
          break;
          
        case RewardType.badge:
          // Para badges que se ganan al completar metas en cierto tiempo
          if (isGoalCompleted && 
              reward.metadata != null &&
              reward.metadata!.containsKey('completionDays') &&
              goal.deadline != null) {
              // Días permitidos para completar (0 significa antes de la fecha límite)
            int targetDays = reward.metadata!['completionDays'];
            int actualDays = DateTime.now().difference(goal.deadline!).inDays;
            
            // Si se completó antes de o justo en la fecha límite (según el valor permitido)
            if (actualDays <= targetDays) {
              await _updateRewardProgress(
                reward.id,
                100,
                true,
                'Completar meta antes del plazo',
              );
            }
          }
          break;
      }
    }
  }
  
  // Verificar y actualizar recompensas basadas en transacciones
  Future<void> checkAndUpdateTransactionBasedRewards(finance.Transaction transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    // Obtener recompensas relacionadas con gastos o ahorros
    final rewardsSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .where('category', whereIn: ['expenses', 'savings'])
      .get();
      
    for (var doc in rewardsSnapshot.docs) {
      final reward = Reward.fromFirestore(doc);
      
      // Si ya está desbloqueada, continuar con la siguiente
      if (reward.isUnlocked) continue;
      
      // Verificar tipo de transacción
      if (transaction.type == 'ingreso' && reward.category == RewardCategory.savings) {
        // Recompensas relacionadas con ahorro
        if (reward.metadata != null && 
            reward.metadata!.containsKey('savingsThreshold')) {
          
          double threshold = reward.metadata!['savingsThreshold'];
          
          // Calcular ahorro total
          final savingsSnapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: 'ingreso')
            .get();
            double totalSavings = 0;
          for (var transDoc in savingsSnapshot.docs) {
            final transData = transDoc.data();
            final trans = finance.Transaction.fromJson(transData);
            trans.id = transDoc.id;
            totalSavings += trans.amount;
          }
          
          double progress = (totalSavings / threshold) * 100;
          bool shouldUnlock = totalSavings >= threshold;
          
          await _updateRewardProgress(
            reward.id,
            progress > 100 ? 100 : progress,
            shouldUnlock,
            'Ahorrar un total de $totalSavings',
          );
        }
      } 
      else if (transaction.type == 'gasto' && reward.category == RewardCategory.expenses) {
        // Recompensas relacionadas con control de gastos
        if (reward.metadata != null && 
            reward.metadata!.containsKey('consecutiveDays')) {
          
          int requiredDays = reward.metadata!['consecutiveDays'];
          
          // Verificar si hay gastos controlados por x días consecutivos
          // Esto necesitaría una lógica más compleja para rastrear días consecutivos
          // Por ahora implementamos una versión simplificada
          
          // Obtener la fecha actual y restar los días requeridos
          final today = DateTime.now();
          final startDate = today.subtract(Duration(days: requiredDays));
          
          // Agrupar transacciones por día
          final expensesSnapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: 'gasto')
            .where('date', isGreaterThanOrEqualTo: startDate)
            .get();
              // Contar días con gastos
          Set<String> daysWithExpenses = {};
          for (var transDoc in expensesSnapshot.docs) {
            final transData = transDoc.data();
            final trans = finance.Transaction.fromJson(transData);
            trans.id = transDoc.id;
            String dayKey = '${trans.date.year}-${trans.date.month}-${trans.date.day}';
            daysWithExpenses.add(dayKey);
          }
          
          int consecutiveDays = daysWithExpenses.length;
          double progress = (consecutiveDays / requiredDays) * 100;
          bool shouldUnlock = consecutiveDays >= requiredDays;
          
          await _updateRewardProgress(
            reward.id,
            progress > 100 ? 100 : progress,
            shouldUnlock,
            'Registrar gastos durante $consecutiveDays días consecutivos',
          );
        }
      }
    }
  }
  
  // Verificar y actualizar recompensas basadas en rachas de uso
  Future<void> checkAndUpdateStreakBasedRewards() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    // Obtener recompensas de tipo racha
    final rewardsSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .where('category', isEqualTo: 'streak')
      .get();
      
    // Obtener el historial de logins del usuario (si existe)
    final userDoc = await _firestore
      .collection('users')
      .doc(userId)
      .get();
      
    final userData = userDoc.data();
    
    if (userData != null && userData.containsKey('loginStreak')) {
      int currentStreak = userData['loginStreak'] ?? 0;
      
      for (var doc in rewardsSnapshot.docs) {
        final reward = Reward.fromFirestore(doc);
        
        // Si ya está desbloqueada, continuar
        if (reward.isUnlocked) continue;
        
        // Verificar si el logro es de tipo racha de login
        if (reward.metadata != null && 
            reward.metadata!.containsKey('streakDays')) {
          
          int requiredDays = reward.metadata!['streakDays'];
          double progress = (currentStreak / requiredDays) * 100;
          bool shouldUnlock = currentStreak >= requiredDays;
          
          await _updateRewardProgress(
            reward.id,
            progress > 100 ? 100 : progress,
            shouldUnlock,
            'Iniciar sesión durante $currentStreak días consecutivos',
          );
        }
      }
    }
  }

  // Actualizar progreso de recompensa
  Future<void> _updateRewardProgress(
    String rewardId, 
    double progress, 
    bool shouldUnlock,
    String triggerAction
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final rewardRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .doc(rewardId);
    
    // Obtener la recompensa actual
    final rewardSnapshot = await rewardRef.get();
    if (!rewardSnapshot.exists) return;
    
    final rewardData = rewardSnapshot.data() as Map<String, dynamic>;
    bool alreadyUnlocked = rewardData['isUnlocked'] ?? false;
    
    // Si ya estaba desbloqueada, no hacer cambios
    if (alreadyUnlocked) return;
    
    // Preparar actualización
    Map<String, dynamic> updateData = {
      'progress': progress,
    };
    
    // Si se debe desbloquear ahora
    if (shouldUnlock) {
      final now = DateTime.now();
      updateData['isUnlocked'] = true;
      updateData['unlockDate'] = now.toIso8601String();
      
      // Añadir al historial de recompensas
      await _firestore
        .collection('users')
        .doc(userId)
        .collection('rewardHistory')
        .add({
          'rewardId': rewardId,
          'rewardTitle': rewardData['title'] ?? 'Logro desbloqueado',
          'unlockDate': now.toIso8601String(),
          'triggerAction': triggerAction,
        });
      
      // Mostrar notificación al usuario
      // Esto podría integrarse con un sistema de notificaciones
    }
    
    // Actualizar la recompensa
    await rewardRef.update(updateData);
  }

  // Inicializar recompensas para un nuevo usuario
  Future<void> initializeUserRewards() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    // Verificar si el usuario ya tiene recompensas
    final existingRewards = await _firestore
      .collection('users')
      .doc(userId)
      .collection('rewards')
      .get();
      
    // Si ya tiene recompensas, no inicializar
    if (existingRewards.docs.isNotEmpty) return;
    
    // Lista de recompensas predefinidas
    final List<Map<String, dynamic>> defaultRewards = [
      // Insignias de ahorro
      {
        'title': 'Primer Ahorro',
        'description': 'Realizar tu primer registro de ahorro',
        'iconPath': 'assets/badges/first_saving.png',
        'type': 'badge',
        'category': 'savings',
        'level': 1,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Registra tu primera entrada de ahorro',
        'metadata': {'savingsThreshold': 1}
      },
      {
        'title': 'Ahorrador Constante',
        'description': 'Ahorrar un total de 1000',
        'iconPath': 'assets/badges/consistent_saver.png',
        'type': 'badge',
        'category': 'savings',
        'level': 2,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Alcanza un ahorro total de 1000',
        'metadata': {'savingsThreshold': 1000}
      },
      {
        'title': 'Experto en Ahorros',
        'description': 'Ahorrar un total de 5000',
        'iconPath': 'assets/badges/savings_expert.png',
        'type': 'badge',
        'category': 'savings',
        'level': 3,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Alcanza un ahorro total de 5000',
        'metadata': {'savingsThreshold': 5000}
      },
      
      // Logros de metas
      {
        'title': 'Primera Meta',
        'description': 'Completa tu primera meta de ahorro',
        'iconPath': 'assets/badges/first_goal.png',
        'type': 'achievement',
        'category': 'goals',
        'level': 1,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Completa cualquier meta de ahorro',
        'metadata': {'goalsCount': 1}
      },
      {
        'title': 'Meta Grande',
        'description': 'Completa una meta de ahorro de al menos 2000',
        'iconPath': 'assets/badges/big_goal.png',
        'type': 'achievement',
        'category': 'goals',
        'level': 3,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Completa una meta de ahorro de 2000 o más',
        'metadata': {'targetAmountThreshold': 2000}
      },
      {
        'title': 'Cumplidor',
        'description': 'Completa una meta antes de su fecha límite',
        'iconPath': 'assets/badges/early_achiever.png',
        'type': 'badge',
        'category': 'goals',
        'level': 2,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Completa cualquier meta antes de su fecha límite',
        'metadata': {'completionDays': 0}
      },
      
      // Hitos de control de gastos
      {
        'title': 'Control de Gastos',
        'description': 'Registra gastos durante 7 días consecutivos',
        'iconPath': 'assets/badges/expense_tracker.png',
        'type': 'milestone',
        'category': 'expenses',
        'level': 1,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Registrar gastos diariamente por 7 días',
        'metadata': {'consecutiveDays': 7}
      },
      {
        'title': 'Control Financiero',
        'description': 'Registra gastos durante 30 días consecutivos',
        'iconPath': 'assets/badges/financial_master.png',
        'type': 'milestone',
        'category': 'expenses',
        'level': 3,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Registrar gastos diariamente por 30 días',
        'metadata': {'consecutiveDays': 30}
      },
      
      // Rachas de uso
      {
        'title': 'Racha de 3 días',
        'description': 'Inicia sesión 3 días seguidos',
        'iconPath': 'assets/badges/streak_3.png',
        'type': 'milestone',
        'category': 'streak',
        'level': 1,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Inicia sesión en la app por 3 días consecutivos',
        'metadata': {'streakDays': 3}
      },
      {
        'title': 'Racha de 7 días',
        'description': 'Inicia sesión 7 días seguidos',
        'iconPath': 'assets/badges/streak_7.png',
        'type': 'milestone',
        'category': 'streak',
        'level': 2,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Inicia sesión en la app por 7 días consecutivos',
        'metadata': {'streakDays': 7}
      },
      {
        'title': 'Racha de 30 días',
        'description': 'Inicia sesión 30 días seguidos',
        'iconPath': 'assets/badges/streak_30.png',
        'type': 'milestone',
        'category': 'streak',
        'level': 3,
        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Inicia sesión en la app por 30 días consecutivos',
        'metadata': {'streakDays': 30}
      },
      
      // Eventos especiales
      {
        'title': 'Perfil Completo',
        'description': 'Completa toda la información de tu perfil',
        'iconPath': 'assets/badges/complete_profile.png',
        'type': 'achievement',
        'category': 'special',
        'level': 1,        'progress': 0,
        'target': 100,
        'isUnlocked': false,
        'criteria': 'Completa todos los campos de tu perfil de usuario',
        'metadata': {'profileFields': true},
      },
    ];
    
    // Crear las recompensas para el usuario
    final batch = _firestore.batch();
    
    for (var rewardData in defaultRewards) {
      final newRewardRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('rewards')
        .doc(); // ID autogenerado
        
      batch.set(newRewardRef, rewardData);
    }
    
    // Ejecutar el lote de operaciones
    await batch.commit();
  }

  // Actualizar la racha de días consecutivos
  Future<void> updateUserLoginStreak() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final userRef = _firestore.collection('users').doc(userId);
    
    // Obtener los datos actuales del usuario
    final userDoc = await userRef.get();
    final userData = userDoc.data() ?? {};
    
    // Obtener la fecha del último login y la racha actual
    DateTime? lastLogin;
    if (userData.containsKey('lastLogin') && userData['lastLogin'] != null) {
      lastLogin = DateTime.parse(userData['lastLogin']);
    }
    
    int currentStreak = userData['loginStreak'] ?? 0;
    final now = DateTime.now();
    
    if (lastLogin != null) {
      // Verificar si el último login fue ayer
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      
      if (lastLoginDate.isAtSameMomentAs(yesterday)) {
        // Si el último login fue ayer, incrementar la racha
        currentStreak += 1;
      } else if (lastLoginDate.isBefore(yesterday)) {
        // Si fue antes de ayer, reiniciar la racha
        currentStreak = 1;
      }
      // Si fue hoy, mantener la racha actual
    } else {
      // Primer login
      currentStreak = 1;
    }
    
    // Actualizar los datos del usuario
    await userRef.set({
      'lastLogin': now.toIso8601String(),
      'loginStreak': currentStreak,
    }, SetOptions(merge: true));
    
    // Verificar las recompensas basadas en rachas
    await checkAndUpdateStreakBasedRewards();
  }
}