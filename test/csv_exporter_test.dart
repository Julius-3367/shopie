import 'package:flutter_test/flutter_test.dart';
import 'package:shopie/models/transaction.dart';
import 'package:shopie/utils/csv_exporter.dart';

void main() {
  group('CsvExporter Tests', () {
    late List<Transaction> sampleTransactions;

    setUp(() {
      sampleTransactions = [
        Transaction.create(
          title: 'Salary',
          amount: 5000.0,
          date: DateTime(2025, 11, 1),
          isIncome: true,
          category: 'Salary',
          notes: 'Monthly salary',
        ),
        Transaction.create(
          title: 'Groceries',
          amount: 150.50,
          date: DateTime(2025, 11, 5),
          isIncome: false,
          category: 'Food & Dining',
          notes: 'Weekly groceries',
        ),
        Transaction.create(
          title: 'Freelance Project',
          amount: 1500.0,
          date: DateTime(2025, 11, 10),
          isIncome: true,
          category: 'Freelance',
        ),
      ];
    });

    group('CSV Generation Tests', () {
      test('should generate CSV string with headers', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('ID'));
        expect(csvString, contains('Date'));
        expect(csvString, contains('Time'));
        expect(csvString, contains('Title'));
        expect(csvString, contains('Category'));
        expect(csvString, contains('Amount'));
        expect(csvString, contains('Type'));
        expect(csvString, contains('Notes'));
      });

      test('should include transaction data in CSV', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('Salary'));
        expect(csvString, contains('5000.00'));
        expect(csvString, contains('Income'));
        expect(csvString, contains('Groceries'));
        expect(csvString, contains('150.50'));
        expect(csvString, contains('Expense'));
      });

      test('should include summary section', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('SUMMARY'));
        expect(csvString, contains('Total Transactions'));
        expect(csvString, contains('Total Income'));
        expect(csvString, contains('Total Expense'));
        expect(csvString, contains('Net Balance'));
      });

      test('should calculate correct totals in summary', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('Total Transactions,3'));
        expect(csvString, contains('Total Income,6500.00')); // 5000 + 1500
        expect(csvString, contains('Total Expense,150.50'));
        expect(csvString, contains('Net Balance,6349.50')); // 6500 - 150.50
      });

      test('should include export metadata', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('Export Date'));
        expect(csvString, contains('Exported by,Shopie Budget Tracker'));
      });

      test('should handle transactions without optional fields', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Simple',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('Simple'));
        expect(csvString, contains('Uncategorized'));
      });

      test('should escape commas in CSV fields', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test, with comma',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          notes: 'Note, with, multiple, commas',
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('"Test, with comma"'));
        expect(csvString, contains('"Note, with, multiple, commas"'));
      });

      test('should escape quotes in CSV fields', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test "quoted" text',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('""quoted""'));
      });

      test('should handle empty transaction list', () {
        // Act
        final csvString = CsvExporter.getCsvString([]);

        // Assert
        expect(csvString, contains('ID,Date,Time'));
        expect(csvString, contains('Total Transactions,0'));
        expect(csvString, contains('Total Income,0.00'));
        expect(csvString, contains('Total Expense,0.00'));
      });
    });

    group('Date Formatting Tests', () {
      test('should format date correctly', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test',
          amount: 100.0,
          date: DateTime(2025, 11, 15, 14, 30, 45),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('2025-11-15'));
        expect(csvString, contains('14:30:45'));
      });
    });

    group('Amount Formatting Tests', () {
      test('should format amount with 2 decimal places', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test',
          amount: 123.456,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('123.46'));
      });

      test('should handle zero amounts', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Zero',
          amount: 0.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('0.00'));
      });

      test('should handle large amounts', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Large',
          amount: 999999.99,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('999999.99'));
      });
    });

    group('Special Characters Tests', () {
      test('should handle newlines in notes', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
          notes: 'Line 1\nLine 2\nLine 3',
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('"Line 1\nLine 2\nLine 3"'));
      });

      test('should handle special characters', () {
        // Arrange
        final transaction = Transaction.create(
          title: 'Test @#\$%^&*()',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains('Test @#\$%^&*()'));
      });
    });

    group('Category Filtering Tests', () {
      test('should generate CSV with income only', () {
        // Arrange
        final incomeTransactions = sampleTransactions
            .where((t) => t.isIncome)
            .toList();

        // Act
        final csvString = CsvExporter.getCsvString(incomeTransactions);

        // Assert
        expect(csvString, contains('Salary'));
        expect(csvString, contains('Freelance Project'));
        expect(csvString, isNot(contains('Groceries')));
      });

      test('should generate CSV with expenses only', () {
        // Arrange
        final expenseTransactions = sampleTransactions
            .where((t) => !t.isIncome)
            .toList();

        // Act
        final csvString = CsvExporter.getCsvString(expenseTransactions);

        // Assert
        expect(csvString, contains('Groceries'));
        expect(csvString, isNot(contains('Salary')));
        expect(csvString, isNot(contains('Freelance')));
      });
    });

    group('CSV Structure Tests', () {
      test('should have proper CSV row structure', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);
        final lines = csvString.split('\n');

        // Assert
        expect(lines.first, startsWith('ID,Date,Time'));
        expect(lines.length, greaterThan(3)); // Headers + data rows + summary
      });

      test('should separate rows with newlines', () {
        // Act
        final csvString = CsvExporter.getCsvString(sampleTransactions);

        // Assert
        expect(csvString, contains('\n'));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle very long transaction titles', () {
        // Arrange
        final longTitle = 'A' * 1000;
        final transaction = Transaction.create(
          title: longTitle,
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([transaction]);

        // Assert
        expect(csvString, contains(longTitle));
      });

      test('should handle multiple transactions with same data', () {
        // Arrange
        final duplicate1 = Transaction.create(
          title: 'Same',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );
        final duplicate2 = Transaction.create(
          title: 'Same',
          amount: 100.0,
          date: DateTime.now(),
          isIncome: true,
        );

        // Act
        final csvString = CsvExporter.getCsvString([duplicate1, duplicate2]);
        final lines = csvString.split('\n');
        final dataLines = lines.where((line) => line.contains('Same')).toList();

        // Assert
        expect(dataLines.length, 2);
      });
    });
  });
}
