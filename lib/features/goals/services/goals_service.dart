import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';
import '../models/progress.dart';

class GoalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una meta
  Future<void> createGoal(Goal goal) async {
    try {
      final docRef = await _firestore.collection('goals').add(goal.toJson());
      goal.id = docRef.id; // Asignar el ID generado por Firestore
    } catch (e) {
      throw Exception('Error al crear la meta: $e');
    }
  }

  // Agregar progreso a una meta
  Future<void> addProgressToGoal(String goalId, Progress progress) async {
    try {
      final docRef = _firestore.collection('goals').doc(goalId);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final goal = Goal.fromJson(goalId, data);

        final updatedProgressHistory = List<Progress>.from(goal.progressHistory)
          ..add(progress);

        final newAmount = goal.currentAmount + progress.amount;

        await docRef.update({
          'progressHistory': updatedProgressHistory.map((p) => p.toJson()).toList(),
          'currentAmount': newAmount > goal.targetAmount ? goal.targetAmount : newAmount,
        });
      }
    } catch (e) {
      throw Exception('Error al agregar progreso: $e');
    }
  }

  // Obtener metas en tiempo real
  Stream<List<Goal>> getGoalsStream() {
    return _firestore.collection('goals').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Goal.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Actualizar una meta
  Future<void> updateGoal(Goal goal) async {
    try {
      await _firestore.collection('goals').doc(goal.id).update(goal.toJson());
    } catch (e) {
      throw Exception('Error al actualizar la meta: $e');
    }
  }

  // Eliminar una meta
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la meta: $e');
    }
  }
}