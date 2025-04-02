import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/transaction.dart';

class FinanceService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  // Guardar una transacción en Firestore
  Future<void> saveTransaction(Transaction transaction) async {
    try {
      final docRef = await _firestore.collection('transactions').add(transaction.toJson());
      transaction.id = docRef.id;
    } catch (e) {
      throw Exception('Error al guardar la transacción: $e');
    }
  }

  // Recuperar todas las transacciones desde Firestore
  Future<List<Transaction>> getTransactions() async {
    try {
      final querySnapshot = await _firestore.collection('transactions').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final transaction = Transaction.fromJson(data);
        transaction.id = doc.id;
        return transaction;
      }).toList();
    } catch (e) {
      throw Exception('Error al recuperar las transacciones: $e');
    }
  }

  // Actualizar una transacción en Firestore
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _firestore.collection('transactions').doc(transaction.id).update(transaction.toJson());
    } catch (e) {
      throw Exception('Error al actualizar la transacción: $e');
    }
  }

  // Eliminar una transacción en Firestore
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la transacción: $e');
    }
  }

  // Obtener transacciones en tiempo real
  Stream<List<Transaction>> getTransactionsStream() {
    return _firestore.collection('transactions').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final transaction = Transaction.fromJson(data);
        transaction.id = doc.id;
        return transaction;
      }).toList();
    });
  }
}