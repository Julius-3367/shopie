import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../utils/category_manager.dart';
import '../utils/currency_manager.dart';

/// Reusable chart widget for displaying transaction data
/// Shows income vs expense breakdown in a pie chart format
class ChartsWidget extends StatelessWidget {
  /// List of transactions to visualize
  final List<Transaction> transactions;

  /// Whether to show the chart legend
  final bool showLegend;

  /// Size of the pie chart
  final double chartSize;

  /// Custom colors for income (optional)
  final Color? incomeColor;

  /// Custom colors for expense (optional)
  final Color? expenseColor;

  const ChartsWidget({
    super.key,
    required this.transactions,
    this.showLegend = true,
    this.chartSize = 200,
    this.incomeColor,
    this.expenseColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals from transactions
    final incomeTotal = _calculateTotalIncome();
    final expenseTotal = _calculateTotalExpense();
    final total = incomeTotal + expenseTotal;

    // Handle empty state
    if (total == 0) {
      return _buildEmptyState();
    }

    // Calculate percentages for display
    final incomePercentage = (incomeTotal / total * 100).toStringAsFixed(1);
    final expensePercentage = (expenseTotal / total * 100).toStringAsFixed(1);

    return showLegend
        ? Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: _buildPieChart(
                  incomeTotal,
                  expenseTotal,
                  incomePercentage,
                  expensePercentage,
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                flex: 2,
                child: _buildLegend(incomeTotal, expenseTotal),
              ),
            ],
          )
        : _buildPieChart(
            incomeTotal,
            expenseTotal,
            incomePercentage,
            expensePercentage,
          );
  }

  /// Build the pie chart widget
  Widget _buildPieChart(
    double incomeTotal,
    double expenseTotal,
    String incomePercentage,
    String expensePercentage,
  ) {
    // Define colors - use custom or default
    final incomeChartColor = incomeColor ?? const Color(0xFF7CB342); // Lime green
    final expenseChartColor = expenseColor ?? const Color(0xFFFF6F00); // Orange

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          // Space between pie sections
          sectionsSpace: 3,
          
          // Center hole radius (0 for full pie, >0 for donut chart)
          centerSpaceRadius: 60,
          
          // Pie chart sections configuration
          sections: [
            // Income section
            PieChartSectionData(
              value: incomeTotal,
              title: '$incomePercentage%',
              color: incomeChartColor,
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
              // Add gradient effect
              gradient: LinearGradient(
                colors: [
                  incomeChartColor,
                  incomeChartColor.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            
            // Expense section
            PieChartSectionData(
              value: expenseTotal,
              title: '$expensePercentage%',
              color: expenseChartColor,
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
              // Add gradient effect
              gradient: LinearGradient(
                colors: [
                  expenseChartColor,
                  expenseChartColor.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
          
          // Touch interaction configuration
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Can add custom touch handling here if needed
            },
          ),
          
          // Start angle in degrees (0 = 3 o'clock position)
          startDegreeOffset: -90,
        ),
        
        // Enable smooth animations
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOutCubic,
      ),
    );
  }

  /// Build the legend showing income and expense breakdown
  Widget _buildLegend(double incomeTotal, double expenseTotal) {
    final incomeChartColor = incomeColor ?? const Color(0xFF7CB342);
    final expenseChartColor = expenseColor ?? const Color(0xFFFF6F00);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income legend item
        _buildLegendItem(
          label: 'Income',
          color: incomeChartColor,
          amount: incomeTotal,
          icon: Icons.arrow_downward,
        ),
        const SizedBox(height: 20),
        
        // Expense legend item
        _buildLegendItem(
          label: 'Expense',
          color: expenseChartColor,
          amount: expenseTotal,
          icon: Icons.arrow_upward,
        ),
      ],
    );
  }

  /// Build individual legend item with label, color indicator, and amount
  Widget _buildLegendItem({
    required String label,
    required Color color,
    required double amount,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with color indicator
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color box indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Icon
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            
            // Label text
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        
        // Amount display
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            CurrencyManager.formatAmount(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state when no transactions exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add transactions to see the chart',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate total income from the transaction list
  /// Filters transactions where isIncome is true and sums their amounts
  double _calculateTotalIncome() {
    return transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculate total expense from the transaction list
  /// Filters transactions where isIncome is false and sums their amounts
  double _calculateTotalExpense() {
    return transactions
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get transactions count by type
  int getIncomeCount() {
    return transactions.where((t) => t.isIncome).length;
  }

  int getExpenseCount() {
    return transactions.where((t) => !t.isIncome).length;
  }

  /// Get income to expense ratio
  /// Returns 0 if no expenses exist
  double getIncomeToExpenseRatio() {
    final expense = _calculateTotalExpense();
    if (expense == 0) return 0;
    return _calculateTotalIncome() / expense;
  }
}

/// Extended chart widget with category breakdown
/// Shows detailed expense breakdown by category with proper colors and icons
class CategoryChartsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final bool showOnlyExpenses;
  final bool showLegend;

  const CategoryChartsWidget({
    super.key,
    required this.transactions,
    this.showOnlyExpenses = true,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions by category
    final categoryData = _groupByCategory();

    if (categoryData.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate total for percentage
    final total = categoryData.values.fold(0.0, (sum, amount) => sum + amount);

    return showLegend
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: _buildPieChart(categoryData, total),
              ),
              const SizedBox(height: 20),
              _buildCategoryLegend(categoryData),
            ],
          )
        : AspectRatio(
            aspectRatio: 1,
            child: _buildPieChart(categoryData, total),
          );
  }

  /// Build pie chart
  Widget _buildPieChart(Map<String, double> categoryData, double total) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _buildCategorySections(categoryData, total),
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Custom touch handling can be added here
          },
        ),
      ),
    );
  }

  /// Build category legend
  Widget _buildCategoryLegend(Map<String, double> categoryData) {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: sortedEntries.map((entry) {
        final categoryColor = CategoryManager.getCategoryColor(
          entry.key,
          !showOnlyExpenses,
        );
        final categoryIcon = CategoryManager.getCategoryIcon(
          entry.key,
          !showOnlyExpenses,
        );
        final percentage = (entry.value / categoryData.values.fold(0.0, (a, b) => a + b) * 100)
            .toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: categoryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcon,
                size: 16,
                color: categoryColor,
              ),
              const SizedBox(width: 6),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Group transactions by category and sum amounts
  Map<String, double> _groupByCategory() {
    final Map<String, double> grouped = {};

    for (var transaction in transactions) {
      // Filter by expense if showOnlyExpenses is true
      if (showOnlyExpenses && transaction.isIncome) continue;
      if (!showOnlyExpenses && !transaction.isIncome) continue;

      final category = transaction.category ?? 'Uncategorized';
      grouped[category] = (grouped[category] ?? 0) + transaction.amount;
    }

    return grouped;
  }

  /// Build pie chart sections from category data with proper colors
  List<PieChartSectionData> _buildCategorySections(
    Map<String, double> categoryData,
    double total,
  ) {
    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = CategoryManager.getCategoryColor(
        entry.key,
        !showOnlyExpenses,
      );

      return PieChartSectionData(
        value: entry.value,
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }).toList();
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No category data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

