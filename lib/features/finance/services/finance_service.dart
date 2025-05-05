import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';

class FinanceService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guardar una transacción en Firestore
  Future<void> saveTransaction(Transaction transaction) async {
    try {
      // Verificar que el usuario esté autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario debe estar autenticado para guardar transacciones');
      }

      // Agregar el ID del usuario a la transacción
      final Map<String, dynamic> data = transaction.toJson();
      data['userId'] = user.uid; // Agregar el ID del usuario

      final docRef = await _firestore.collection('transactions').add(data);
      transaction.id = docRef.id;
    } catch (e) {
      throw Exception('Error al guardar la transacción: $e');
    }
  }

  // Recuperar transacciones del usuario actual
  Future<List<Transaction>> getTransactions() async {
    try {
      // Verificar que el usuario esté autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario debe estar autenticado para obtener transacciones');
      }

      // Filtrar por el ID del usuario actual
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

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
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario debe estar autenticado para actualizar transacciones');
      }

      // Mantener el ID del usuario
      final Map<String, dynamic> data = transaction.toJson();
      data['userId'] = user.uid;

      await _firestore.collection('transactions').doc(transaction.id).update(data);
    } catch (e) {
      throw Exception('Error al actualizar la transacción: $e');
    }
  }

  // Eliminar una transacción en Firestore
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario debe estar autenticado para eliminar transacciones');
      }

      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la transacción: $e');
    }
  }

  // Obtener transacciones en tiempo real
  Stream<List<Transaction>> getTransactionsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      // Retornar un stream vacío si el usuario no está autenticado
      return Stream.value([]);
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final transaction = Transaction.fromJson(data);
        transaction.id = doc.id;
        return transaction;
      }).toList();
    });
  }
}