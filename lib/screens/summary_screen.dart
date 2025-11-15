import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/currency_manager.dart';

/// Screen displaying financial summaries with charts and statistics
/// Includes pie charts, bar charts, and period filters
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedPeriod = 'Monthly'; // Daily, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Financial Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E), // Dark blue
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = _getFilteredTransactions(provider);
          final totalIncome = _calculateIncome(transactions);
          final totalExpense = _calculateExpense(transactions);
          final categoryData = _getCategoryData(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTransactions();
            },
            color: const Color(0xFF7CB342), // Lime green
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Period Filter Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A237E), // Dark blue
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'View Period',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPeriodSelector(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Overview Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildOverviewCard(
                            'Total Income',
                            totalIncome,
                            const Color(0xFF7CB342), // Lime green
                            Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOverviewCard(
                            'Total Expense',
                            totalExpense,
                            const Color(0xFFFF6F00), // Orange
                            Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Net Balance Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildNetBalanceCard(totalIncome - totalExpense),
                  ),

                  const SizedBox(height: 24),

                  // Pie Chart Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildChartCard(
                      'Income vs Expense',
                      _buildPieChart(totalIncome, totalExpense),
                      height: 280,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Breakdown Chart
                  if (categoryData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildChartCard(
                        'Expense by Category',
                        _buildBarChart(categoryData),
                        height: 300,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Statistics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStatisticsCard(
                      transactions,
                      totalIncome,
                      totalExpense,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build period selector buttons
  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Daily'),
          _buildPeriodButton('Weekly'),
          _buildPeriodButton('Monthly'),
        ],
      ),
    );
  }

  /// Build individual period button
  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7CB342) // Lime green
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// Build overview card
  Widget _buildOverviewCard(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyManager.formatAmount(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build net balance card
  Widget _buildNetBalanceCard(double balance) {
    final isPositive = balance >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF7CB342), const Color(0xFF8E24AA)] // Lime green to Violet
              : [const Color(0xFFFF6F00), const Color(0xFF6D4C41)], // Orange to Maroon
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPositive
                    ? const Color(0xFF7CB342)
                    : const Color(0xFFFF6F00))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Net Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${isPositive ? '+' : ''}${CurrencyManager.formatAmount(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build chart card container
  Widget _buildChartCard(String title, Widget chart, {double height = 250}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E), // Dark blue
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: height,
            child: chart,
          ),
        ],
      ),
    );
  }

  /// Build pie chart for income vs expense
  Widget _buildPieChart(double income, double expense) {
    if (income == 0 && expense == 0) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final total = income + expense;
    final incomePercent = (income / total * 100).toStringAsFixed(1);
    final expensePercent = (expense / total * 100).toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: income,
                  title: '$incomePercent%',
                  color: const Color(0xFF7CB342), // Lime green
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: expense,
                  title: '$expensePercent%',
                  color: const Color(0xFFFF6F00), // Orange
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                'Income',
                const Color(0xFF7CB342),
                income,
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                'Expense',
                const Color(0xFFFF6F00),
                expense,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build legend item for pie chart
  Widget _buildLegendItem(String label, Color color, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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

  /// Build bar chart for category breakdown
  Widget _buildBarChart(Map<String, double> categoryData) {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedEntries.take(5).toList();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: topCategories.isEmpty
                  ? 100
                  : topCategories.first.value * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      CurrencyManager.formatAmount(rod.toY),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= topCategories.length) {
                        return const SizedBox.shrink();
                      }
                      final category = topCategories[value.toInt()].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _abbreviateCategory(category),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${CurrencyManager.getCurrencySymbol()}${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: topCategories.isEmpty
                    ? 20
                    : topCategories.first.value / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                topCategories.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: topCategories[index].value,
                      color: _getCategoryColor(index),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build statistics card
  Widget _buildStatisticsCard(
    List<Transaction> transactions,
    double income,
    double expense,
  ) {
    final avgIncome =
        transactions.where((t) => t.isIncome).isEmpty
            ? 0.0
            : income / transactions.where((t) => t.isIncome).length;
    final avgExpense =
        transactions.where((t) => !t.isIncome).isEmpty
            ? 0.0
            : expense / transactions.where((t) => !t.isIncome).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Transactions',
            transactions.length.toString(),
            Icons.receipt_long,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Average Income',
            CurrencyManager.formatAmount(avgIncome),
            Icons.arrow_downward,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Average Expense',
            CurrencyManager.formatAmount(avgExpense),
            Icons.arrow_upward,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Savings Rate',
            income == 0
                ? '0%'
                : '${((income - expense) / income * 100).toStringAsFixed(1)}%',
            Icons.savings,
          ),
        ],
      ),
    );
  }

  /// Build statistics row
  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8E24AA).withOpacity(0.1), // Violet
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8E24AA), // Violet
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  /// Get filtered transactions based on selected period
  List<Transaction> _getFilteredTransactions(TransactionProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case 'Daily':
        return provider.transactions.where((t) {
          final transactionDate =
              DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate == today;
        }).toList();

      case 'Weekly':
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return provider.getTransactionsByDateRange(weekStart, weekEnd);

      case 'Monthly':
        return provider.currentMonthTransactions;

      default:
        return provider.transactions;
    }
  }

  /// Calculate total income from transactions
  double _calculateIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expense from transactions
  double _calculateExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get expense data grouped by category
  Map<String, double> _getCategoryData(List<Transaction> transactions) {
    final Map<String, double> categoryData = {};

    for (var transaction in transactions) {
      if (!transaction.isIncome && transaction.category != null) {
        categoryData[transaction.category!] =
            (categoryData[transaction.category!] ?? 0) + transaction.amount;
      }
    }

    return categoryData;
  }

  /// Abbreviate long category names for chart display
  String _abbreviateCategory(String category) {
    if (category.length <= 10) return category;
    final words = category.split(' ');
    if (words.length > 1) {
      return words.map((w) => w[0]).join('.');
    }
    return category.substring(0, 8) + '..';
  }

  /// Get color for category bar
  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFFFF6F00), // Orange
      const Color(0xFF6D4C41), // Maroon
      const Color(0xFF8E24AA), // Violet
      const Color(0xFF1A237E), // Dark blue
      const Color(0xFF7CB342), // Lime green
    ];
    return colors[index % colors.length];
  }
}
