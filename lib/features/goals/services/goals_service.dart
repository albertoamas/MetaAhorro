import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal.dart';
import '../models/progress.dart';
import '../../rewards/services/rewards_service.dart';

class GoalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final RewardsService _rewardsService; 
  
  GoalsService() {
    _rewardsService = RewardsService();
  }
  // Crear una meta
  Future<void> createGoal(Goal goal) async {
    try {
      // Asegurarse de que el userId esté establecido
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Asegurarse de que la meta tenga el userId correcto
      final goalWithUserId = goal.copyWith(userId: userId);
      
      final docRef = await _firestore.collection('goals').add(goalWithUserId.toJson());
      goal.id = docRef.id; // Asignar el ID generado por Firestore
    } catch (e) {
      throw Exception('Error al crear la meta: $e');
    }
  }
  // Agregar progreso a una meta
  Future<void> addProgressToGoal(String goalId, Progress progress) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final docRef = _firestore.collection('goals').doc(goalId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw Exception('La meta no existe');
      }
      
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Verificar que la meta pertenezca al usuario actual
      if (data['userId'] != userId) {
        throw Exception('No tienes permiso para modificar esta meta');
      }
      
      final goal = Goal.fromJson(goalId, data);

      final updatedProgressHistory = List<Progress>.from(goal.progressHistory)
        ..add(progress);

      final newAmount = goal.currentAmount + progress.amount;
      final updatedAmount = newAmount > goal.targetAmount ? goal.targetAmount : newAmount;
      
      // Actualizar la meta
      final updatedGoal = goal.copyWith(
        currentAmount: updatedAmount,
        progressHistory: updatedProgressHistory,
      );

      await docRef.update({
        'progressHistory': updatedProgressHistory.map((p) => p.toJson()).toList(),
        'currentAmount': updatedAmount,
      });

      // Verificar si la meta se ha completado con este progreso
      if (updatedAmount >= goal.targetAmount) {
        // Llamar al servicio de recompensas para verificar logros
        try {
          await _rewardsService.checkAndUpdateGoalBasedRewards(updatedGoal);
        } catch (e) {
          print('Error al verificar recompensas: $e');
        }
      }
    } catch (e) {
      throw Exception('Error al agregar progreso: $e');
    }
  }// Obtener metas en tiempo real
  Stream<List<Goal>> getGoalsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // Si no hay usuario autenticado, devolver una lista vacía
      return Stream.value([]);
    }
    
    return _firestore
      .collection('goals')
      .where('userId', isEqualTo: userId) // Filtrar por userId del usuario actual
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return Goal.fromJson(doc.id, doc.data());
        }).toList();
      });
  }
  // Actualizar una meta
  Future<void> updateGoal(Goal goal) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Verificar que la meta pertenezca al usuario actual
      final goalDoc = await _firestore.collection('goals').doc(goal.id).get();
      if (!goalDoc.exists) {
        throw Exception('La meta no existe');
      }
      
      final goalData = goalDoc.data() as Map<String, dynamic>;
      if (goalData['userId'] != userId) {
        throw Exception('No tienes permiso para actualizar esta meta');
      }
      
      await _firestore.collection('goals').doc(goal.id).update(goal.toJson());
      
      // Verificar si la meta está completa para actualizar recompensas
      if (goal.currentAmount >= goal.targetAmount) {
        try {
          await _rewardsService.checkAndUpdateGoalBasedRewards(goal);
        } catch (e) {
          print('Error al verificar recompensas: $e');
        }
      }
    } catch (e) {
      throw Exception('Error al actualizar la meta: $e');
    }
  }
  // Eliminar una meta
  Future<void> deleteGoal(String goalId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Verificar que la meta pertenezca al usuario actual
      final goalDoc = await _firestore.collection('goals').doc(goalId).get();
      if (!goalDoc.exists) {
        throw Exception('La meta no existe');
      }
      
      final goalData = goalDoc.data() as Map<String, dynamic>;
      if (goalData['userId'] != userId) {
        throw Exception('No tienes permiso para eliminar esta meta');
      }
      
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la meta: $e');
    }
  }
}