import 'package:flutter_test/flutter_test.dart';
import 'package:shopie/utils/category_manager.dart';

void main() {
  group('CategoryManager Tests', () {
    group('Category Lists Tests', () {
      test('should have 8 income categories', () {
        // Act
        final incomeCategories = CategoryManager.incomeCategoryNames;

        // Assert
        expect(incomeCategories.length, 8);
        expect(incomeCategories, contains('Salary'));
        expect(incomeCategories, contains('Freelance'));
        expect(incomeCategories, contains('Business'));
      });

      test('should have 15 expense categories', () {
        // Act
        final expenseCategories = CategoryManager.expenseCategoryNames;

        // Assert
        expect(expenseCategories.length, 15);
        expect(expenseCategories, contains('Food & Dining'));
        expect(expenseCategories, contains('Shopping'));
        expect(expenseCategories, contains('Transportation'));
      });

      test('income category names should be sorted', () {
        // Act
        final categories = CategoryManager.incomeCategoryNames;

        // Assert
        final sorted = List<String>.from(categories)..sort();
        expect(categories, equals(sorted));
      });

      test('expense category names should be sorted', () {
        // Act
        final categories = CategoryManager.expenseCategoryNames;

        // Assert
        final sorted = List<String>.from(categories)..sort();
        expect(categories, equals(sorted));
      });
    });

    group('Get Category Data Tests', () {
      test('should get income category data', () {
        // Act
        final categoryData = CategoryManager.getCategoryData('Salary', true);

        // Assert
        expect(categoryData, isNotNull);
        expect(categoryData?.name, 'Salary');
        expect(categoryData?.icon, isNotNull);
        expect(categoryData?.color, isNotNull);
        expect(categoryData?.description, isNotEmpty);
      });

      test('should get expense category data', () {
        // Act
        final categoryData = CategoryManager.getCategoryData('Food & Dining', false);

        // Assert
        expect(categoryData, isNotNull);
        expect(categoryData?.name, 'Food & Dining');
        expect(categoryData?.icon, isNotNull);
        expect(categoryData?.color, isNotNull);
      });

      test('should return null for non-existent income category', () {
        // Act
        final categoryData = CategoryManager.getCategoryData('NonExistent', true);

        // Assert
        expect(categoryData, isNull);
      });

      test('should return null for non-existent expense category', () {
        // Act
        final categoryData = CategoryManager.getCategoryData('NonExistent', false);

        // Assert
        expect(categoryData, isNull);
      });
    });

    group('Get Category Icon Tests', () {
      test('should get icon for existing income category', () {
        // Act
        final icon = CategoryManager.getCategoryIcon('Salary', true);

        // Assert
        expect(icon, isNotNull);
      });

      test('should get icon for existing expense category', () {
        // Act
        final icon = CategoryManager.getCategoryIcon('Shopping', false);

        // Assert
        expect(icon, isNotNull);
      });

      test('should return default icon for non-existent income category', () {
        // Act
        final icon = CategoryManager.getCategoryIcon('NonExistent', true);

        // Assert
        expect(icon, isNotNull); // Should return default icon
      });

      test('should return default icon for non-existent expense category', () {
        // Act
        final icon = CategoryManager.getCategoryIcon('NonExistent', false);

        // Assert
        expect(icon, isNotNull); // Should return default icon
      });
    });

    group('Get Category Color Tests', () {
      test('should get color for existing income category', () {
        // Act
        final color = CategoryManager.getCategoryColor('Salary', true);

        // Assert
        expect(color, isNotNull);
      });

      test('should get color for existing expense category', () {
        // Act
        final color = CategoryManager.getCategoryColor('Food & Dining', false);

        // Assert
        expect(color, isNotNull);
      });

      test('should return default color for non-existent income category', () {
        // Act
        final color = CategoryManager.getCategoryColor('NonExistent', true);

        // Assert
        expect(color, isNotNull);
      });

      test('should return default color for non-existent expense category', () {
        // Act
        final color = CategoryManager.getCategoryColor('NonExistent', false);

        // Assert
        expect(color, isNotNull);
      });
    });

    group('Default Category Tests', () {
      test('should get default income category', () {
        // Act
        final defaultCategory = CategoryManager.getDefaultCategory(true);

        // Assert
        expect(defaultCategory, 'Salary');
      });

      test('should get default expense category', () {
        // Act
        final defaultCategory = CategoryManager.getDefaultCategory(false);

        // Assert
        expect(defaultCategory, 'Food & Dining');
      });
    });

    group('Category Exists Tests', () {
      test('should return true for existing income category', () {
        // Act
        final exists = CategoryManager.categoryExists('Salary', true);

        // Assert
        expect(exists, true);
      });

      test('should return true for existing expense category', () {
        // Act
        final exists = CategoryManager.categoryExists('Shopping', false);

        // Assert
        expect(exists, true);
      });

      test('should return false for non-existent income category', () {
        // Act
        final exists = CategoryManager.categoryExists('NonExistent', true);

        // Assert
        expect(exists, false);
      });

      test('should return false for non-existent expense category', () {
        // Act
        final exists = CategoryManager.categoryExists('NonExistent', false);

        // Assert
        expect(exists, false);
      });

      test('should return false when checking income category with wrong type', () {
        // Act - Check 'Salary' (income) as expense
        final exists = CategoryManager.categoryExists('Salary', false);

        // Assert
        expect(exists, false);
      });
    });

    group('All Categories Tests', () {
      test('should get all categories combined', () {
        // Act
        final allCategories = CategoryManager.allCategories;

        // Assert
        expect(allCategories.length, 23); // 8 income + 15 expense
        expect(allCategories, contains('Salary'));
        expect(allCategories, contains('Shopping'));
      });
    });

    group('Category Data Tests', () {
      test('category data should have all required fields', () {
        // Act
        final categoryData = CategoryManager.getCategoryData('Salary', true);

        // Assert
        expect(categoryData?.name, isNotEmpty);
        expect(categoryData?.icon, isNotNull);
        expect(categoryData?.color, isNotNull);
        expect(categoryData?.description, isNotEmpty);
      });

      test('all income categories should have valid data', () {
        // Act
        for (var category in CategoryManager.incomeCategoryNames) {
          final data = CategoryManager.getCategoryData(category, true);

          // Assert
          expect(data, isNotNull, reason: 'Category $category has no data');
          expect(data?.name, category);
          expect(data?.icon, isNotNull);
          expect(data?.color, isNotNull);
          expect(data?.description, isNotEmpty);
        }
      });

      test('all expense categories should have valid data', () {
        // Act
        for (var category in CategoryManager.expenseCategoryNames) {
          final data = CategoryManager.getCategoryData(category, false);

          // Assert
          expect(data, isNotNull, reason: 'Category $category has no data');
          expect(data?.name, category);
          expect(data?.icon, isNotNull);
          expect(data?.color, isNotNull);
          expect(data?.description, isNotEmpty);
        }
      });
    });

    group('Category Color Consistency Tests', () {
      test('should use colors from specified palette', () {
        // Arrange
        final allowedColors = [
          const Color(0xFF7CB342), // Lime green
          const Color(0xFF1A237E), // Dark blue
          const Color(0xFFFF6F00), // Orange
          const Color(0xFF6D4C41), // Maroon
          const Color(0xFF8E24AA), // Violet
          const Color(0xFF9E9E9E), // Gray
        ];

        // Act & Assert
        for (var category in CategoryManager.allCategories.keys) {
          final isIncome = CategoryManager.categoryExists(category, true);
          final color = CategoryManager.getCategoryColor(category, isIncome);
          
          expect(
            allowedColors.contains(color),
            true,
            reason: 'Category $category uses color outside specified palette',
          );
        }
      });
    });
  });
}
