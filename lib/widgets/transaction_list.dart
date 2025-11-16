import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../screens/edit_transaction_screen.dart';
import '../utils/category_manager.dart';

/// Widget that displays a list of transactions
/// Groups transactions by date and shows them in a scrollable list
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  
  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(transactions);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dateTransactions = groupedTransactions[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                top: 16,
                bottom: 8,
              ),
              child: Text(
                _formatDateHeader(dateKey),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Transaction tiles for this date
            ...dateTransactions.map((transaction) {
              return TransactionTile(
                transaction: transaction,
                key: ValueKey(transaction.id),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  /// Group transactions by date
  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  /// Format date header to show relative dates
  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(transactionDate).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }
}

/// Individual transaction tile widget
/// Displays transaction details with swipe-to-delete functionality
class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.horizontal,
      background: _buildEditBackground(),
      secondaryBackground: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        } else if (direction == DismissDirection.startToEnd) {
          // Edit action
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTransactionScreen(
                transaction: transaction,
              ),
            ),
          );
          return false; // Don't dismiss
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteTransaction(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showTransactionDetails(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: transaction.isIncome
                          ? const Color(0xFF7CB342).withOpacity(0.1) // Lime green
                          : const Color(0xFFFF6F00).withOpacity(0.1), // Orange
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: transaction.isIncome
                          ? const Color(0xFF7CB342) // Lime green
                          : const Color(0xFFFF6F00), // Orange
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E), // Dark blue
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (transaction.category != null) ...[
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction.category!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a').format(transaction.date),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) => Text(
                          '${transaction.isIncome ? '+' : '-'}${currencyProvider.formatAmount(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: transaction.isIncome
                                ? const Color(0xFF7CB342) // Lime green
                                : const Color(0xFFFF6F00), // Orange
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: transaction.isIncome
                              ? const Color(0xFF7CB342).withOpacity(0.1)
                              : const Color(0xFFFF6F00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.isIncome ? 'Income' : 'Expense',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: transaction.isIncome
                                ? const Color(0xFF7CB342)
                                : const Color(0xFFFF6F00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the dismiss background (shown when swiping)
  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F00), // Orange
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the edit background (shown when swiping left)
  Widget _buildEditBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3), // Blue
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Edit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Get appropriate icon based on category using CategoryManager
  IconData _getCategoryIcon() {
    if (transaction.category == null) {
      return transaction.isIncome
          ? Icons.arrow_downward
          : Icons.arrow_upward;
    }

    return CategoryManager.getCategoryIcon(
      transaction.category!,
      transaction.isIncome,
    );
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF6F00), // Orange
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Delete Transaction'),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${transaction.title}"?\n\nThis action cannot be undone.',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00), // Orange
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Delete transaction using provider
  void _deleteTransaction(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    provider.deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${transaction.title} deleted'),
        backgroundColor: const Color(0xFF6D4C41), // Maroon
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Add back the transaction
            provider.addTransaction(transaction);
          },
        ),
      ),
    );
  }

  /// Show transaction details in bottom sheet
  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: transaction.isIncome
                        ? const Color(0xFF7CB342).withOpacity(0.1)
                        : const Color(0xFFFF6F00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: transaction.isIncome
                        ? const Color(0xFF7CB342)
                        : const Color(0xFFFF6F00),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.category ?? 'No Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Amount
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) => _buildDetailRow(
                'Amount',
                '${transaction.isIncome ? '+' : '-'}${currencyProvider.formatAmount(transaction.amount)}',
                transaction.isIncome
                    ? const Color(0xFF7CB342)
                    : const Color(0xFFFF6F00),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _buildDetailRow(
              'Date',
              DateFormat('MMMM dd, yyyy • h:mm a').format(transaction.date),
              const Color(0xFF1A237E),
            ),
            const SizedBox(height: 16),

            // Type
            _buildDetailRow(
              'Type',
              transaction.isIncome ? 'Income' : 'Expense',
              transaction.isIncome
                  ? const Color(0xFF7CB342)
                  : const Color(0xFFFF6F00),
            ),

            // Notes
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transaction.notes!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build detail row in bottom sheet
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
