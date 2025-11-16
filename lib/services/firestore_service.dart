import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model;

/// Service class to handle Firestore operations for transactions
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get transactions collection reference for a specific user
  CollectionReference _getUserTransactionsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  /// Stream of transactions for a user
  Stream<List<model.Transaction>> getTransactionsStream(String userId) {
    return _getUserTransactionsCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return model.Transaction(
          id: doc.id,
          title: data['title'] as String,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'] as String,
          date: (data['date'] as Timestamp).toDate(),
          isIncome: data['isIncome'] as bool,
          notes: data['notes'] as String?,
        );
      }).toList();
    });
  }

  /// Get all transactions for a user (one-time fetch)
  Future<List<model.Transaction>> getTransactions(String userId) async {
    final snapshot = await _getUserTransactionsCollection(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return model.Transaction(
        id: doc.id,
        title: data['title'] as String,
        amount: (data['amount'] as num).toDouble(),
        category: data['category'] as String,
        date: (data['date'] as Timestamp).toDate(),
        isIncome: data['isIncome'] as bool,
        notes: data['notes'] as String?,
      );
    }).toList();
  }

  /// Add a transaction to Firestore
  Future<void> addTransaction(String userId, model.Transaction transaction) async {
    await _getUserTransactionsCollection(userId).doc(transaction.id).set({
      'title': transaction.title,
      'amount': transaction.amount,
      'category': transaction.category,
      'date': Timestamp.fromDate(transaction.date),
      'isIncome': transaction.isIncome,
      'notes': transaction.notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a transaction in Firestore
  Future<void> updateTransaction(String userId, model.Transaction transaction) async {
    await _getUserTransactionsCollection(userId).doc(transaction.id).update({
      'title': transaction.title,
      'amount': transaction.amount,
      'category': transaction.category,
      'date': Timestamp.fromDate(transaction.date),
      'isIncome': transaction.isIncome,
      'notes': transaction.notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a transaction from Firestore
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _getUserTransactionsCollection(userId).doc(transactionId).delete();
  }

  /// Delete all transactions for a user
  Future<void> deleteAllTransactions(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _getUserTransactionsCollection(userId).get();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  /// Sync local transactions to Firestore (for migration)
  Future<void> syncLocalTransactions(
    String userId,
    List<model.Transaction> transactions,
  ) async {
    final batch = _firestore.batch();
    
    for (var transaction in transactions) {
      final docRef = _getUserTransactionsCollection(userId).doc(transaction.id);
      batch.set(docRef, {
        'title': transaction.title,
        'amount': transaction.amount,
        'category': transaction.category,
        'date': Timestamp.fromDate(transaction.date),
        'isIncome': transaction.isIncome,
        'notes': transaction.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  /// Create user profile document
  Future<void> createUserProfile(String userId, String email, String displayName) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
}
