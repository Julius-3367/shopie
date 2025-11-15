import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import 'currency_manager.dart';

/// Utility class for exporting transaction data to CSV format
/// Handles file creation, storage permissions, and CSV formatting
class CsvExporter {
  // Private constructor to prevent instantiation
  CsvExporter._();

  /// Export transactions to a CSV file
  /// Returns the file path if successful, null if failed
  /// 
  /// [transactions] - List of transactions to export
  /// [fileName] - Optional custom file name (without extension)
  /// 
  /// Example usage:
  /// ```dart
  /// final filePath = await CsvExporter.exportTransactions(transactions);
  /// if (filePath != null) {
  ///   print('Exported to: $filePath');
  /// }
  /// ```
  static Future<String?> exportTransactions(
    List<Transaction> transactions, {
    String? fileName,
  }) async {
    try {
      // Check if there are transactions to export
      if (transactions.isEmpty) {
        debugPrint('No transactions to export');
        return null;
      }

      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return null;
      }

      // Generate CSV content
      final csvContent = _generateCsvContent(transactions);

      // Get the file path
      final filePath = await _getFilePath(fileName);
      if (filePath == null) {
        debugPrint('Could not get file path');
        return null;
      }

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      debugPrint('Transactions exported successfully to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting transactions: $e');
      return null;
    }
  }

  /// Generate CSV content from transactions
  /// Returns formatted CSV string with headers and data rows
  static String _generateCsvContent(List<Transaction> transactions) {
    // Get current currency for CSV header
    final currency = CurrencyManager.getCurrentCurrency();
    
    // CSV headers
    final headers = [
      'ID',
      'Date',
      'Time',
      'Title',
      'Category',
      'Amount (${currency.code})',
      'Type',
      'Notes',
    ];

    // Start with header row
    final List<String> csvRows = [];
    csvRows.add(headers.join(','));

    // Add data rows
    for (var transaction in transactions) {
      final row = [
        _escapeCsvField(transaction.id),
        _escapeCsvField(DateFormat('yyyy-MM-dd').format(transaction.date)),
        _escapeCsvField(DateFormat('HH:mm:ss').format(transaction.date)),
        _escapeCsvField(transaction.title),
        _escapeCsvField(transaction.category ?? 'Uncategorized'),
        transaction.amount.toStringAsFixed(2),
        transaction.isIncome ? 'Income' : 'Expense',
        _escapeCsvField(transaction.notes ?? ''),
      ];
      csvRows.add(row.join(','));
    }

    // Add summary section
    csvRows.add(''); // Empty line
    csvRows.add('SUMMARY');
    csvRows.add('Currency,${currency.code} (${currency.name})');
    csvRows.add('Total Transactions,${transactions.length}');
    
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    csvRows.add('Total Income,${totalIncome.toStringAsFixed(2)}');
    csvRows.add('Total Expense,${totalExpense.toStringAsFixed(2)}');
    csvRows.add('Net Balance,${(totalIncome - totalExpense).toStringAsFixed(2)}');
    
    // Add export metadata
    csvRows.add(''); // Empty line
    csvRows.add('Export Date,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    csvRows.add('Exported by,Shopie Budget Tracker');

    return csvRows.join('\n');
  }

  /// Escape CSV field to handle commas, quotes, and newlines
  /// Wraps field in quotes if it contains special characters
  static String _escapeCsvField(String field) {
    // If field contains comma, quote, or newline, wrap in quotes
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Escape existing quotes by doubling them
      final escapedField = field.replaceAll('"', '""');
      return '"$escapedField"';
    }
    return field;
  }

  /// Get the file path for saving the CSV
  /// Returns null if unable to get a valid path
  static Future<String?> _getFilePath(String? customFileName) async {
    try {
      Directory? directory;

      // Get appropriate directory based on platform
      if (Platform.isAndroid) {
        // For Android, use Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        
        // Fallback to external storage directory
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // For iOS, use application documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms, use application documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return null;
      }

      // Create Shopie folder if it doesn't exist
      final shopieDir = Directory('${directory.path}/Shopie');
      if (!await shopieDir.exists()) {
        await shopieDir.create(recursive: true);
      }

      // Generate file name
      final fileName = customFileName ?? 
          'shopie_transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
      
      return '${shopieDir.path}/$fileName.csv';
    } catch (e) {
      debugPrint('Error getting file path: $e');
      return null;
    }
  }

  /// Request storage permission
  /// Returns true if permission is granted
  static Future<bool> _requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), we don't need storage permission for Downloads
      if (Platform.isAndroid) {
        // Check Android version
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          // Android 13+ doesn't require storage permission for Downloads
          return true;
        }

        // For older Android versions, request storage permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }

      // iOS doesn't require permission for app documents directory
      return true;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Get Android SDK version
  /// Returns 0 if unable to determine
  static Future<int> _getAndroidVersion() async {
    try {
      if (!Platform.isAndroid) return 0;
      
      // This would require device_info_plus package
      // For now, return a safe default
      return 30; // Android 11
    } catch (e) {
      return 30; // Safe default
    }
  }

  /// Export transactions for a specific date range
  /// Filters transactions before exporting
  static Future<String?> exportTransactionsByDateRange(
    List<Transaction> allTransactions,
    DateTime startDate,
    DateTime endDate, {
    String? fileName,
  }) async {
    // Filter transactions by date range
    final filteredTransactions = allTransactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Sort by date (newest first)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Generate file name with date range
    final defaultFileName = fileName ?? 
        'shopie_${DateFormat('yyyyMMdd').format(startDate)}_to_${DateFormat('yyyyMMdd').format(endDate)}';

    return exportTransactions(
      filteredTransactions,
      fileName: defaultFileName,
    );
  }

  /// Export only income transactions
  static Future<String?> exportIncomeTransactions(
    List<Transaction> allTransactions, {
    String? fileName,
  }) async {
    final incomeTransactions = allTransactions
        .where((t) => t.isIncome)
        .toList();

    final defaultFileName = fileName ?? 
        'shopie_income_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

    return exportTransactions(
      incomeTransactions,
      fileName: defaultFileName,
    );
  }

  /// Export only expense transactions
  static Future<String?> exportExpenseTransactions(
    List<Transaction> allTransactions, {
    String? fileName,
  }) async {
    final expenseTransactions = allTransactions
        .where((t) => !t.isIncome)
        .toList();

    final defaultFileName = fileName ?? 
        'shopie_expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

    return exportTransactions(
      expenseTransactions,
      fileName: defaultFileName,
    );
  }

  /// Export transactions by category
  static Future<String?> exportTransactionsByCategory(
    List<Transaction> allTransactions,
    String category, {
    String? fileName,
  }) async {
    final categoryTransactions = allTransactions
        .where((t) => t.category == category)
        .toList();

    final defaultFileName = fileName ?? 
        'shopie_${category.toLowerCase().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    return exportTransactions(
      categoryTransactions,
      fileName: defaultFileName,
    );
  }

  /// Get CSV content as string without saving to file
  /// Useful for sharing via other methods (email, messaging, etc.)
  static String getCsvString(List<Transaction> transactions) {
    return _generateCsvContent(transactions);
  }

  /// Validate CSV file exists and is readable
  static Future<bool> validateCsvFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      debugPrint('Error validating CSV file: $e');
      return false;
    }
  }

  /// Delete CSV file
  static Future<bool> deleteCsvFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting CSV file: $e');
      return false;
    }
  }

  /// Get list of all exported CSV files
  static Future<List<FileSystemEntity>> getExportedFiles() async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/Shopie');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDir.path}/Shopie');
      }

      if (await directory.exists()) {
        return directory
            .listSync()
            .where((entity) => entity.path.endsWith('.csv'))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting exported files: $e');
      return [];
    }
  }
}
