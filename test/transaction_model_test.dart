import 'package:flutter_test/flutter_test.dart';
import 'package:shopie/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    group('Transaction Creation Tests', () {
      test('should create transaction with all fields', () {
        // Arrange & Act
        final transaction = Transaction(
          id: '123',
          title: 'Test Transaction',
          amount: 100.0,
          date: DateTime(2025, 11, 15),
          isIncome: true,
          category: 'Salary',
          notes: 'Test notes',
        );

        // Assert
        expect(transaction.id, '123');
        expect(transaction.title, 'Test Transaction');
        expect(transaction.amount, 100.0);
        expect(transaction.date, DateTime(2025, 11, 15));
        expect(transaction.isIncome, true);
        expect(transaction.category, 'Salary');
        expect(transaction.notes, 'Test notes');
      });

      test('should create transaction with factory method', () {
        // Act
        final transaction = Transaction.create(
          title: 'Salary',
          amount: 5000.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        // Assert
        expect(transaction.id, isNotEmpty);
        expect(transaction.title, 'Salary');
        expect(transaction.amount, 5000.0);
        expect(transaction.isIncome, true);
      });

      test('should generate unique IDs for different transactions', () {
        // Act
        final transaction1 = Transaction.create(
          title: 'Trans 1',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Small delay to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 10));

        final transaction2 = Transaction.create(
          title: 'Trans 2',
          amount: 200.0,
          date: DateTime.now(),
          isIncome: false,
        );

        // Assert
        expect(transaction1.id, isNot(equals(transaction2.id)));
      });

      test('should create transaction without optional fields', () {
        // Act
        final transaction = Transaction.create(
          title: 'Simple Transaction',
          amount: 50.0,
          date: DateTime.now(),
          isIncome: false,
        );

        // Assert
        expect(transaction.category, isNull);
        expect(transaction.notes, isNull);
      });
    });

    group('Transaction Serialization Tests', () {
      test('should convert transaction to map', () {
        // Arrange
        final date = DateTime(2025, 11, 15, 10, 30);
        final transaction = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
          category: 'Salary',
          notes: 'Test notes',
        );

        // Act
        final map = transaction.toMap();

        // Assert
        expect(map['id'], '123');
        expect(map['title'], 'Test');
        expect(map['amount'], 100.0);
        expect(map['date'], date.toIso8601String());
        expect(map['isIncome'], true);
        expect(map['category'], 'Salary');
        expect(map['notes'], 'Test notes');
      });

      test('should create transaction from map', () {
        // Arrange
        final date = DateTime(2025, 11, 15, 10, 30);
        final map = {
          'id': '123',
          'title': 'Test',
          'amount': 100.0,
          'date': date.toIso8601String(),
          'isIncome': true,
          'category': 'Salary',
          'notes': 'Test notes',
        };

        // Act
        final transaction = Transaction.fromMap(map);

        // Assert
        expect(transaction.id, '123');
        expect(transaction.title, 'Test');
        expect(transaction.amount, 100.0);
        expect(transaction.date, date);
        expect(transaction.isIncome, true);
        expect(transaction.category, 'Salary');
        expect(transaction.notes, 'Test notes');
      });

      test('should handle integer amount in fromMap', () {
        // Arrange
        final map = {
          'id': '123',
          'title': 'Test',
          'amount': 100, // Integer instead of double
          'date': DateTime.now().toIso8601String(),
          'isIncome': true,
        };

        // Act
        final transaction = Transaction.fromMap(map);

        // Assert
        expect(transaction.amount, 100.0);
        expect(transaction.amount, isA<double>());
      });
    });

    group('Transaction Copy Tests', () {
      test('should copy transaction with new values', () {
        // Arrange
        final original = Transaction.create(
          title: 'Original',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
        );

        // Act
        final copied = original.copyWith(
          title: 'Updated',
          amount: 200.0,
        );

        // Assert
        expect(copied.title, 'Updated');
        expect(copied.amount, 200.0);
        expect(copied.id, original.id); // ID should remain same
        expect(copied.isIncome, original.isIncome);
      });

      test('should keep original values when not specified in copyWith', () {
        // Arrange
        final original = Transaction.create(
          title: 'Original',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          category: 'Salary',
          notes: 'Original notes',
        );

        // Act
        final copied = original.copyWith(title: 'Updated');

        // Assert
        expect(copied.title, 'Updated');
        expect(copied.amount, original.amount);
        expect(copied.category, original.category);
        expect(copied.notes, original.notes);
      });
    });

    group('Transaction Equality Tests', () {
      test('should be equal when all fields are same', () {
        // Arrange
        final date = DateTime(2025, 11, 15);
        final transaction1 = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
          category: 'Salary',
        );

        final transaction2 = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
          category: 'Salary',
        );

        // Assert
        expect(transaction1, equals(transaction2));
        expect(transaction1.hashCode, equals(transaction2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final date = DateTime(2025, 11, 15);
        final transaction1 = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
        );

        final transaction2 = Transaction(
          id: '456',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
        );

        // Assert
        expect(transaction1, isNot(equals(transaction2)));
      });

      test('should not be equal when amounts differ', () {
        // Arrange
        final date = DateTime(2025, 11, 15);
        final transaction1 = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: date,
          isIncome: true,
        );

        final transaction2 = Transaction(
          id: '123',
          title: 'Test',
          amount: 200.0,
          date: date,
          isIncome: true,
        );

        // Assert
        expect(transaction1, isNot(equals(transaction2)));
      });
    });

    group('Transaction toString Tests', () {
      test('should generate correct string representation', () {
        // Arrange
        final transaction = Transaction(
          id: '123',
          title: 'Test',
          amount: 100.0,
          date: DateTime(2025, 11, 15),
          isIncome: true,
          category: 'Salary',
          notes: 'Test notes',
        );

        // Act
        final string = transaction.toString();

        // Assert
        expect(string, contains('123'));
        expect(string, contains('Test'));
        expect(string, contains('100.0'));
        expect(string, contains('true'));
        expect(string, contains('Salary'));
      });
    });

    group('Transaction Edge Cases', () {
      test('should handle zero amount', () {
        // Act
        final transaction = Transaction.create(
          title: 'Zero',
          amount: 0.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Assert
        expect(transaction.amount, 0.0);
      });

      test('should handle large amounts', () {
        // Act
        final transaction = Transaction.create(
          title: 'Large',
          amount: 999999999.99,
          date: DateTime.now(),
          isIncome: true,
        );

        // Assert
        expect(transaction.amount, 999999999.99);
      });

      test('should handle decimal amounts', () {
        // Act
        final transaction = Transaction.create(
          title: 'Decimal',
          amount: 123.45,
          date: DateTime.now(),
          isIncome: true,
        );

        // Assert
        expect(transaction.amount, 123.45);
      });

      test('should handle very long titles', () {
        // Arrange
        final longTitle = 'A' * 1000;

        // Act
        final transaction = Transaction.create(
          title: longTitle,
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Assert
        expect(transaction.title.length, 1000);
      });

      test('should handle special characters in title', () {
        // Act
        final transaction = Transaction.create(
          title: 'Test @#\$%^&*()_+-=[]{}|;:,.<>?',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Assert
        expect(transaction.title, contains('@#\$%'));
      });
    });
  });
}
