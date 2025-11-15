import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/category_manager.dart';
import '../utils/currency_manager.dart';
import '../widgets/charts_widget.dart';

/// Screen displaying category-wise statistics and breakdowns
/// Shows spending/income patterns by category
class CategoryStatsScreen extends StatefulWidget {
  const CategoryStatsScreen({super.key});

  @override
  State<CategoryStatsScreen> createState() => _CategoryStatsScreenState();
}

class _CategoryStatsScreenState extends State<CategoryStatsScreen> {
  bool _showExpenses = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Category Breakdown',
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
          final transactions = _showExpenses
              ? provider.expenseTransactions
              : provider.incomeTransactions;

          final categoryData = _getCategoryBreakdown(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTransactions();
            },
            color: const Color(0xFF7CB342),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Type Toggle Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A237E),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'View Categories',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTypeToggle(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Pie Chart
                  if (transactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
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
                        child: CategoryChartsWidget(
                          transactions: transactions,
                          showOnlyExpenses: _showExpenses,
                          showLegend: true,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Category List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
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
                            'Category Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (categoryData.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No ${_showExpenses ? "expense" : "income"} data available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...categoryData.entries.map((entry) {
                              final percentage = (entry.value /
                                      categoryData.values.fold(
                                          0.0, (a, b) => a + b) *
                                      100)
                                  .toStringAsFixed(1);
                              final categoryIcon =
                                  CategoryManager.getCategoryIcon(
                                entry.key,
                                !_showExpenses,
                              );
                              final categoryColor =
                                  CategoryManager.getCategoryColor(
                                entry.key,
                                !_showExpenses,
                              );

                              return Column(
                                children: [
                                  _buildCategoryItem(
                                    entry.key,
                                    entry.value,
                                    percentage,
                                    categoryIcon,
                                    categoryColor,
                                  ),
                                  if (entry.key !=
                                      categoryData.keys.last)
                                    const Divider(height: 24),
                                ],
                              );
                            }).toList(),
                        ],
                      ),
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

  /// Build type toggle (Income/Expense)
  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showExpenses = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showExpenses
                      ? const Color(0xFF7CB342)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: !_showExpenses ? Colors.white : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: !_showExpenses ? Colors.white : Colors.white70,
                        fontWeight: !_showExpenses
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showExpenses = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showExpenses
                      ? const Color(0xFFFF6F00)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _showExpenses ? Colors.white : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expense',
                      style: TextStyle(
                        color: _showExpenses ? Colors.white : Colors.white70,
                        fontWeight:
                            _showExpenses ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build category item
  Widget _buildCategoryItem(
    String category,
    double amount,
    String percentage,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage% of total',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          CurrencyManager.formatAmount(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Get category breakdown from transactions
  Map<String, double> _getCategoryBreakdown(List<dynamic> transactions) {
    final Map<String, double> breakdown = {};

    for (var transaction in transactions) {
      final category = transaction.category ?? 'Uncategorized';
      breakdown[category] = (breakdown[category] ?? 0) + transaction.amount;
    }

    // Sort by amount (highest first)
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }
}
