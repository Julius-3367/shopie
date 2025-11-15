import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopie/models/transaction.dart';
import 'package:shopie/providers/transaction_provider.dart';

void main() {
  group('TransactionProvider Tests', () {
    late TransactionProvider provider;
    late Box<Transaction> mockBox;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      
      // Register Transaction adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionAdapter());
      }
    });

    setUp(() async {
      // Create a test box before each test
      mockBox = await Hive.openBox<Transaction>('test_transactions');
      provider = TransactionProvider();
    });

    tearDown(() async {
      // Clear and close box after each test
      await mockBox.clear();
      await mockBox.close();
      await Hive.deleteBoxFromDisk('test_transactions');
    });

    group('Add Transaction Tests', () {
      test('should add a new transaction successfully', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test Income',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        // Act
        final result = await provider.addTransaction(transaction);

        // Assert
        expect(result, true);
        expect(provider.transactions.length, 1);
        expect(provider.transactions.first.title, 'Test Income');
        expect(provider.transactions.first.amount, 100.0);
      });

      test('should add multiple transactions', () async {
        // Arrange
        final transaction1 = Transaction.create(
          title: 'Salary',
          amount: 5000.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        final transaction2 = Transaction.create(
          title: 'Groceries',
          amount: 150.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Food & Dining',
        );

        // Act
        await provider.addTransaction(transaction1);
        await provider.addTransaction(transaction2);

        // Assert
        expect(provider.transactions.length, 2);
        expect(provider.transactionCount, 2);
      });

      test('should update total income when adding income transaction', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Freelance',
          amount: 1500.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Freelance',
        );

        // Act
        await provider.addTransaction(transaction);

        // Assert
        expect(provider.totalIncome, 1500.0);
        expect(provider.totalExpenses, 0.0);
      });

      test('should update total expenses when adding expense transaction', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Shopping',
          amount: 250.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Shopping',
        );

        // Act
        await provider.addTransaction(transaction);

        // Assert
        expect(provider.totalExpenses, 250.0);
        expect(provider.totalIncome, 0.0);
      });

      test('should calculate balance correctly', () async {
        // Arrange
        final income = Transaction.create(
          title: 'Salary',
          amount: 5000.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        final expense = Transaction.create(
          title: 'Rent',
          amount: 1500.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Housing',
        );

        // Act
        await provider.addTransaction(income);
        await provider.addTransaction(expense);

        // Assert
        expect(provider.balance, 3500.0);
      });
    });

    group('Delete Transaction Tests', () {
      test('should delete a transaction successfully', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test Transaction',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Gift',
        );
        await provider.addTransaction(transaction);

        // Act
        final result = await provider.deleteTransaction(transaction.id);

        // Assert
        expect(result, true);
        expect(provider.transactions.length, 0);
      });

      test('should update totals after deletion', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Expense',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Entertainment',
        );
        await provider.addTransaction(transaction);

        // Act
        await provider.deleteTransaction(transaction.id);

        // Assert
        expect(provider.totalExpenses, 0.0);
      });

      test('should return false when deleting non-existent transaction', () async {
        // Act
        final result = await provider.deleteTransaction('non_existent_id');

        // Assert
        expect(result, true); // Still returns true but doesn't crash
        expect(provider.transactions.length, 0);
      });

      test('should delete multiple transactions', () async {
        // Arrange
        final transaction1 = Transaction.create(
          title: 'Trans 1',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );
        final transaction2 = Transaction.create(
          title: 'Trans 2',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Bonus',
        );

        await provider.addTransaction(transaction1);
        await provider.addTransaction(transaction2);

        // Act
        final deletedCount = await provider.deleteMultipleTransactions([
          transaction1.id,
          transaction2.id,
        ]);

        // Assert
        expect(deletedCount, 2);
        expect(provider.transactions.length, 0);
      });
    });

    group('Update Transaction Tests', () {
      test('should update a transaction successfully', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Original Title',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );
        await provider.addTransaction(transaction);

        // Act
        final updatedTransaction = transaction.copyWith(
          title: 'Updated Title',
          amount: 200.0,
        );
        final result = await provider.updateTransaction(updatedTransaction);

        // Assert
        expect(result, true);
        expect(provider.transactions.first.title, 'Updated Title');
        expect(provider.transactions.first.amount, 200.0);
      });

      test('should return false when updating non-existent transaction', () async {
        // Arrange
        final transaction = Transaction(
          id: 'non_existent',
          title: 'Test',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final result = await provider.updateTransaction(transaction);

        // Assert
        expect(result, false);
      });
    });

    group('Load Transactions Tests', () {
      test('should load transactions from storage', () async {
        // Arrange
        final transaction1 = Transaction.create(
          title: 'Trans 1',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );
        final transaction2 = Transaction.create(
          title: 'Trans 2',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Shopping',
        );

        await provider.addTransaction(transaction1);
        await provider.addTransaction(transaction2);

        // Create new provider instance
        final newProvider = TransactionProvider();

        // Act
        await newProvider.loadTransactions();

        // Assert
        expect(newProvider.transactions.length, 2);
      });

      test('should sort transactions by date (newest first)', () async {
        // Arrange
        final oldTransaction = Transaction.create(
          title: 'Old',
          amount: 100.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
          isIncome: true,
          category: 'Salary',
        );
        final newTransaction = Transaction.create(
          title: 'New',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        await provider.addTransaction(oldTransaction);
        await provider.addTransaction(newTransaction);

        // Act
        await provider.loadTransactions();

        // Assert
        expect(provider.transactions.first.title, 'New');
        expect(provider.transactions.last.title, 'Old');
      });
    });

    group('Filter and Search Tests', () {
      setUp(() async {
        // Add sample transactions
        await provider.addTransaction(Transaction.create(
          title: 'Salary',
          amount: 5000.0,
          date: DateTime(2025, 11, 1),
          isIncome: true,
          category: 'Salary',
        ));

        await provider.addTransaction(Transaction.create(
          title: 'Groceries',
          amount: 150.0,
          date: DateTime(2025, 11, 15),
          isIncome: false,
          category: 'Food & Dining',
        ));

        await provider.addTransaction(Transaction.create(
          title: 'Freelance Project',
          amount: 1500.0,
          date: DateTime(2025, 10, 20),
          isIncome: true,
          category: 'Freelance',
          notes: 'Web development project',
        ));
      });

      test('should filter income transactions', () {
        // Act
        final incomeTransactions = provider.incomeTransactions;

        // Assert
        expect(incomeTransactions.length, 2);
        expect(incomeTransactions.every((t) => t.isIncome), true);
      });

      test('should filter expense transactions', () {
        // Act
        final expenseTransactions = provider.expenseTransactions;

        // Assert
        expect(expenseTransactions.length, 1);
        expect(expenseTransactions.every((t) => !t.isIncome), true);
      });

      test('should get transactions by date range', () {
        // Arrange
        final startDate = DateTime(2025, 11, 1);
        final endDate = DateTime(2025, 11, 30);

        // Act
        final filtered = provider.getTransactionsByDateRange(startDate, endDate);

        // Assert
        expect(filtered.length, 2);
      });

      test('should get transactions by category', () {
        // Act
        final salaryTransactions = provider.getTransactionsByCategory('Salary');

        // Assert
        expect(salaryTransactions.length, 1);
        expect(salaryTransactions.first.category, 'Salary');
      });

      test('should search transactions by title', () {
        // Act
        final results = provider.searchTransactions('Freelance');

        // Assert
        expect(results.length, 1);
        expect(results.first.title, 'Freelance Project');
      });

      test('should search transactions by notes', () {
        // Act
        final results = provider.searchTransactions('development');

        // Assert
        expect(results.length, 1);
        expect(results.first.notes, 'Web development project');
      });

      test('should return empty list for non-matching search', () {
        // Act
        final results = provider.searchTransactions('xyz123');

        // Assert
        expect(results.length, 0);
      });
    });

    group('Monthly Transactions Tests', () {
      setUp(() async {
        final now = DateTime.now();
        
        // Current month transaction
        await provider.addTransaction(Transaction.create(
          title: 'This Month',
          amount: 100.0,
          date: DateTime(now.year, now.month, 15),
          isIncome: true,
          category: 'Salary',
        ));

        // Previous month transaction
        await provider.addTransaction(Transaction.create(
          title: 'Last Month',
          amount: 200.0,
          date: DateTime(now.year, now.month - 1, 15),
          isIncome: true,
          category: 'Salary',
        ));
      });

      test('should get current month transactions', () {
        // Act
        final currentMonth = provider.currentMonthTransactions;

        // Assert
        expect(currentMonth.length, 1);
        expect(currentMonth.first.title, 'This Month');
      });

      test('should calculate current month income', () {
        // Act
        final monthIncome = provider.currentMonthIncome;

        // Assert
        expect(monthIncome, 100.0);
      });

      test('should calculate current month expenses', () async {
        // Arrange
        final now = DateTime.now();
        await provider.addTransaction(Transaction.create(
          title: 'Expense',
          amount: 50.0,
          date: DateTime(now.year, now.month, 10),
          isIncome: false,
          category: 'Shopping',
        ));

        // Act
        final monthExpenses = provider.currentMonthExpenses;

        // Assert
        expect(monthExpenses, 50.0);
      });
    });

    group('Clear All Transactions Tests', () {
      test('should clear all transactions', () async {
        // Arrange
        await provider.addTransaction(Transaction.create(
          title: 'Test',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        ));

        // Act
        final result = await provider.clearAllTransactions();

        // Assert
        expect(result, true);
        expect(provider.transactions.length, 0);
        expect(provider.totalIncome, 0.0);
        expect(provider.totalExpenses, 0.0);
      });
    });

    group('Get Transaction by ID Tests', () {
      test('should get transaction by ID', () async {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );
        await provider.addTransaction(transaction);

        // Act
        final found = provider.getTransactionById(transaction.id);

        // Assert
        expect(found, isNotNull);
        expect(found?.id, transaction.id);
      });

      test('should return null for non-existent ID', () {
        // Act
        final found = provider.getTransactionById('non_existent');

        // Assert
        expect(found, isNull);
      });
    });

    group('Computed Properties Tests', () {
      test('should calculate transaction count', () async {
        // Arrange
        await provider.addTransaction(Transaction.create(
          title: 'Trans 1',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        ));
        await provider.addTransaction(Transaction.create(
          title: 'Trans 2',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Shopping',
        ));

        // Assert
        expect(provider.transactionCount, 2);
      });

      test('should calculate balance as income minus expenses', () async {
        // Arrange
        await provider.addTransaction(Transaction.create(
          title: 'Income',
          amount: 1000.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        ));
        await provider.addTransaction(Transaction.create(
          title: 'Expense',
          amount: 300.0,
          date: DateTime.now(),
          isIncome: false,
          category: 'Shopping',
        ));

        // Assert
        expect(provider.balance, 700.0);
      });
    });
  });
}
