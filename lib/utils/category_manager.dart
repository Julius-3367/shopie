import 'package:flutter/material.dart';

/// Centralized category management for the app
/// Provides predefined categories with icons and colors
class CategoryManager {
  // Private constructor to prevent instantiation
  CategoryManager._();

  /// Income categories with metadata
  static final Map<String, CategoryData> incomeCategories = {
    'Salary': CategoryData(
      name: 'Salary',
      icon: Icons.work,
      color: const Color(0xFF7CB342), // Lime green
      description: 'Regular salary or wages',
    ),
    'Freelance': CategoryData(
      name: 'Freelance',
      icon: Icons.computer,
      color: const Color(0xFF8E24AA), // Violet
      description: 'Freelance work and projects',
    ),
    'Business': CategoryData(
      name: 'Business',
      icon: Icons.business,
      color: const Color(0xFF1A237E), // Dark blue
      description: 'Business income',
    ),
    'Investment': CategoryData(
      name: 'Investment',
      icon: Icons.trending_up,
      color: const Color(0xFF7CB342), // Lime green
      description: 'Returns from investments',
    ),
    'Gift': CategoryData(
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: const Color(0xFF8E24AA), // Violet
      description: 'Gifts and donations received',
    ),
    'Bonus': CategoryData(
      name: 'Bonus',
      icon: Icons.stars,
      color: const Color(0xFF7CB342), // Lime green
      description: 'Bonuses and rewards',
    ),
    'Rental': CategoryData(
      name: 'Rental',
      icon: Icons.home,
      color: const Color(0xFF1A237E), // Dark blue
      description: 'Rental income',
    ),
    'Other Income': CategoryData(
      name: 'Other Income',
      icon: Icons.attach_money,
      color: const Color(0xFF9E9E9E), // Gray
      description: 'Other sources of income',
    ),
  };

  /// Expense categories with metadata
  static final Map<String, CategoryData> expenseCategories = {
    'Food & Dining': CategoryData(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: const Color(0xFFFF6F00), // Orange
      description: 'Groceries, restaurants, food delivery',
    ),
    'Shopping': CategoryData(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: const Color(0xFF6D4C41), // Maroon
      description: 'Clothing, accessories, general shopping',
    ),
    'Transportation': CategoryData(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: const Color(0xFF1A237E), // Dark blue
      description: 'Fuel, public transport, vehicle maintenance',
    ),
    'Bills & Utilities': CategoryData(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: const Color(0xFFFF6F00), // Orange
      description: 'Electricity, water, internet, phone',
    ),
    'Entertainment': CategoryData(
      name: 'Entertainment',
      icon: Icons.movie,
      color: const Color(0xFF8E24AA), // Violet
      description: 'Movies, games, subscriptions',
    ),
    'Healthcare': CategoryData(
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: const Color(0xFF6D4C41), // Maroon
      description: 'Medical expenses, medicines, insurance',
    ),
    'Education': CategoryData(
      name: 'Education',
      icon: Icons.school,
      color: const Color(0xFF1A237E), // Dark blue
      description: 'Tuition, books, courses',
    ),
    'Travel': CategoryData(
      name: 'Travel',
      icon: Icons.flight,
      color: const Color(0xFF8E24AA), // Violet
      description: 'Vacation, trips, accommodation',
    ),
    'Housing': CategoryData(
      name: 'Housing',
      icon: Icons.home_work,
      color: const Color(0xFFFF6F00), // Orange
      description: 'Rent, mortgage, property tax',
    ),
    'Personal Care': CategoryData(
      name: 'Personal Care',
      icon: Icons.face,
      color: const Color(0xFF6D4C41), // Maroon
      description: 'Salon, spa, grooming',
    ),
    'Fitness': CategoryData(
      name: 'Fitness',
      icon: Icons.fitness_center,
      color: const Color(0xFF7CB342), // Lime green
      description: 'Gym, sports, fitness equipment',
    ),
    'Gifts & Donations': CategoryData(
      name: 'Gifts & Donations',
      icon: Icons.volunteer_activism,
      color: const Color(0xFF8E24AA), // Violet
      description: 'Gifts given, charitable donations',
    ),
    'Insurance': CategoryData(
      name: 'Insurance',
      icon: Icons.security,
      color: const Color(0xFF1A237E), // Dark blue
      description: 'Life, health, vehicle insurance',
    ),
    'Pets': CategoryData(
      name: 'Pets',
      icon: Icons.pets,
      color: const Color(0xFF6D4C41), // Maroon
      description: 'Pet food, veterinary, pet supplies',
    ),
    'Other Expense': CategoryData(
      name: 'Other Expense',
      icon: Icons.more_horiz,
      color: const Color(0xFF9E9E9E), // Gray
      description: 'Miscellaneous expenses',
    ),
  };

  /// Get all income category names
  static List<String> get incomeCategoryNames =>
      incomeCategories.keys.toList()..sort();

  /// Get all expense category names
  static List<String> get expenseCategoryNames =>
      expenseCategories.keys.toList()..sort();

  /// Get category data by name
  static CategoryData? getCategoryData(String categoryName, bool isIncome) {
    if (isIncome) {
      return incomeCategories[categoryName];
    } else {
      return expenseCategories[categoryName];
    }
  }

  /// Get icon for category
  static IconData getCategoryIcon(String categoryName, bool isIncome) {
    final categoryData = getCategoryData(categoryName, isIncome);
    return categoryData?.icon ?? 
        (isIncome ? Icons.arrow_downward : Icons.arrow_upward);
  }

  /// Get color for category
  static Color getCategoryColor(String categoryName, bool isIncome) {
    final categoryData = getCategoryData(categoryName, isIncome);
    return categoryData?.color ?? 
        (isIncome ? const Color(0xFF7CB342) : const Color(0xFFFF6F00));
  }

  /// Get default category for income/expense
  static String getDefaultCategory(bool isIncome) {
    return isIncome ? 'Salary' : 'Food & Dining';
  }

  /// Check if category exists
  static bool categoryExists(String categoryName, bool isIncome) {
    if (isIncome) {
      return incomeCategories.containsKey(categoryName);
    } else {
      return expenseCategories.containsKey(categoryName);
    }
  }

  /// Get all categories (income + expense)
  static Map<String, CategoryData> get allCategories {
    return {...incomeCategories, ...expenseCategories};
  }

  /// Get category statistics from transactions
  static Map<String, int> getCategoryUsageCount(
    List<dynamic> transactions,
    bool isIncome,
  ) {
    final Map<String, int> usageCount = {};
    
    for (var transaction in transactions) {
      if (transaction.isIncome == isIncome && transaction.category != null) {
        usageCount[transaction.category!] = 
            (usageCount[transaction.category!] ?? 0) + 1;
      }
    }
    
    return usageCount;
  }

  /// Get most used categories
  static List<String> getMostUsedCategories(
    List<dynamic> transactions,
    bool isIncome, {
    int limit = 5,
  }) {
    final usageCount = getCategoryUsageCount(transactions, isIncome);
    final sortedEntries = usageCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries
        .take(limit)
        .map((e) => e.key)
        .toList();
  }
}

/// Category data model
class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}
