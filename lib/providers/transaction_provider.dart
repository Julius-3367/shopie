import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/transaction.dart';
import '../services/hive_boxes.dart';
import '../services/firestore_service.dart';

/// Provider class for managing transaction state and operations
/// Handles CRUD operations for transactions and syncs with Hive storage and Firestore
class TransactionProvider extends ChangeNotifier {
  // Private list to store all transactions
  List<Transaction> _transactions = [];
  FirestoreService? _firestoreService;
  String? _userId;
  bool _firebaseAvailable = false;

  TransactionProvider() {
    _init();
  }

  void _init() async {
    try {
      await Firebase.app();
      _firebaseAvailable = true;
      _firestoreService = FirestoreService();
      debugPrint('Firestore service initialized');
    } catch (e) {
      debugPrint('Firebase not available, using local storage only: $e');
      _firebaseAvailable = false;
    }
  }

  // Getter for transactions (returns unmodifiable list to prevent external modifications)
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Get transactions filtered by income/expense
  List<Transaction> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<Transaction> get expenseTransactions =>
      _transactions.where((t) => !t.isIncome).toList();

  /// Calculate total income
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses
  double get totalExpenses {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate current balance (income - expenses)
  double get balance => totalIncome - totalExpenses;

  /// Set user ID and load their transactions
  Future<void> setUser(String userId) async {
    _userId = userId;
    await loadTransactions();
  }

  /// Clear user data on logout
  void clearUser() {
    _userId = null;
    _transactions = [];
    notifyListeners();
  }

  /// Load all transactions from Hive storage and sync with Firestore
  /// Should be called when the app starts or when provider is initialized
  /// Returns true if load was successful, false otherwise
  Future<bool> loadTransactions() async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return false;
      }

      // Load from local Hive first for fast UI
      _transactions = box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      // If user is logged in, sync with Firestore
      if (_userId != null && _firebaseAvailable && _firestoreService != null) {
        try {
          final firestoreTransactions = await _firestoreService!.getTransactions(_userId!);
          
          // Merge Firestore data with local (Firestore is source of truth)
          _transactions = firestoreTransactions;
          
          // Update local Hive storage
          await box.clear();
          for (var transaction in _transactions) {
            await box.put(transaction.id, transaction);
          }
          
          notifyListeners();
        } catch (e) {
          debugPrint('Error syncing with Firestore: $e');
          // Continue with local data if Firestore fails
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      return false;
    }
  }

  /// Add a new transaction to the list and save to Hive and Firestore
  /// Returns true if the transaction was added successfully
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return false;
      }

      // Save to Hive using the transaction ID as key
      await box.put(transaction.id, transaction);

      // Add to local list and sort
      _transactions.add(transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      notifyListeners();

      // Sync to Firestore if user is logged in
      if (_userId != null && _firebaseAvailable && _firestoreService != null) {
        try {
          await _firestoreService!.addTransaction(_userId!, transaction);
        } catch (e) {
          debugPrint('Error syncing to Firestore: $e');
          // Continue even if Firestore sync fails
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  /// Update an existing transaction
  /// Returns true if the transaction was updated successfully
  Future<bool> updateTransaction(Transaction updatedTransaction) async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return false;
      }

      // Find the index of the transaction to update
      final index =
          _transactions.indexWhere((t) => t.id == updatedTransaction.id);

      if (index == -1) {
        debugPrint('Transaction not found');
        return false;
      }

      // Update in Hive
      await box.put(updatedTransaction.id, updatedTransaction);

      // Update in local list and resort
      _transactions[index] = updatedTransaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      notifyListeners();

      // Sync to Firestore if user is logged in
      if (_userId != null && _firebaseAvailable && _firestoreService != null) {
        try {
          await _firestoreService!.updateTransaction(_userId!, updatedTransaction);
        } catch (e) {
          debugPrint('Error syncing update to Firestore: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  /// Delete a transaction by ID
  /// Returns true if the transaction was deleted successfully
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return false;
      }

      // Delete from Hive
      await box.delete(transactionId);

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);

      notifyListeners();

      // Sync to Firestore if user is logged in
      if (_userId != null && _firebaseAvailable && _firestoreService != null) {
        try {
          await _firestoreService!.deleteTransaction(_userId!, transactionId);
        } catch (e) {
          debugPrint('Error syncing delete to Firestore: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  /// Delete multiple transactions at once
  /// Returns the number of successfully deleted transactions
  Future<int> deleteMultipleTransactions(List<String> transactionIds) async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return 0;
      }

      int deletedCount = 0;

      // Delete from Hive
      for (String id in transactionIds) {
        await box.delete(id);
        deletedCount++;
      }

      // Remove from local list
      _transactions.removeWhere((t) => transactionIds.contains(t.id));

      notifyListeners();
      return deletedCount;
    } catch (e) {
      debugPrint('Error deleting multiple transactions: $e');
      return 0;
    }
  }

  /// Get transactions for a specific date range
  List<Transaction> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _transactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          t.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get transactions by category
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  /// Get transactions for current month
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  /// Get income for current month
  double get currentMonthIncome {
    return currentMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get expenses for current month
  double get currentMonthExpenses {
    return currentMonthTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Clear all transactions (with confirmation in UI)
  /// Use with caution - this deletes all transaction data
  Future<bool> clearAllTransactions() async {
    try {
      final box = HiveBoxes.transactions;
      if (box == null) {
        debugPrint('Transaction box is not open');
        return false;
      }

      await box.clear();
      _transactions.clear();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error clearing all transactions: $e');
      return false;
    }
  }

  /// Get transaction by ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total count of transactions
  int get transactionCount => _transactions.length;

  /// Search transactions by title or notes
  List<Transaction> searchTransactions(String query) {
    final lowerQuery = query.toLowerCase();
    return _transactions.where((t) {
      return t.title.toLowerCase().contains(lowerQuery) ||
          (t.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
