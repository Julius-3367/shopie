import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

/// Utility class for managing Hive boxes and adapters
/// Centralizes all Hive-related initialization and box name constants
class HiveBoxes {
  // Private constructor to prevent instantiation
  HiveBoxes._();

  /// Box name constants
  static const String transactionBox = 'transactions';
  static const String categoryBox = 'categories';
  static const String settingsBox = 'settings';
  static const String budgetBox = 'budgets';

  /// Initialize Hive by registering all adapters and opening boxes
  /// This should be called once during app startup before runApp()
  /// 
  /// Throws [HiveError] if initialization fails
  static Future<void> init() async {
    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionAdapter());
      }

      // Open all boxes
      await Future.wait([
        Hive.openBox<Transaction>(transactionBox),
        Hive.openBox(categoryBox),
        Hive.openBox(settingsBox),
        Hive.openBox(budgetBox),
      ]);
    } catch (e) {
      // Log error in production or rethrow for debugging
      throw HiveError('Failed to initialize Hive: $e');
    }
  }

  /// Get the transaction box
  /// Returns null if the box hasn't been opened yet
  static Box<Transaction>? get transactions {
    if (Hive.isBoxOpen(transactionBox)) {
      return Hive.box<Transaction>(transactionBox);
    }
    return null;
  }

  /// Get the category box
  /// Returns null if the box hasn't been opened yet
  static Box? get categories {
    if (Hive.isBoxOpen(categoryBox)) {
      return Hive.box(categoryBox);
    }
    return null;
  }

  /// Get the settings box
  /// Returns null if the box hasn't been opened yet
  static Box? get settings {
    if (Hive.isBoxOpen(settingsBox)) {
      return Hive.box(settingsBox);
    }
    return null;
  }

  /// Get the budget box
  /// Returns null if the box hasn't been opened yet
  static Box? get budgets {
    if (Hive.isBoxOpen(budgetBox)) {
      return Hive.box(budgetBox);
    }
    return null;
  }

  /// Close all open Hive boxes
  /// Should be called when the app is disposed or during cleanup
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all data from all boxes
  /// Use with caution - this will delete all stored data
  static Future<void> clearAll() async {
    await Future.wait([
      if (Hive.isBoxOpen(transactionBox))
        Hive.box<Transaction>(transactionBox).clear(),
      if (Hive.isBoxOpen(categoryBox)) Hive.box(categoryBox).clear(),
      if (Hive.isBoxOpen(settingsBox)) Hive.box(settingsBox).clear(),
      if (Hive.isBoxOpen(budgetBox)) Hive.box(budgetBox).clear(),
    ]);
  }

  /// Delete all boxes and their data
  /// More thorough than clearAll() - removes the box files themselves
  static Future<void> deleteAll() async {
    await Future.wait([
      Hive.deleteBoxFromDisk(transactionBox),
      Hive.deleteBoxFromDisk(categoryBox),
      Hive.deleteBoxFromDisk(settingsBox),
      Hive.deleteBoxFromDisk(budgetBox),
    ]);
  }
}
