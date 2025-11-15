import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/category_manager.dart';

/// Screen for editing an existing transaction
/// Pre-fills form with transaction data and allows updates
class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  late bool _isIncome;
  late String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing transaction data
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: widget.transaction.notes ?? '');
    _selectedDate = widget.transaction.date;
    _isIncome = widget.transaction.isIncome;
    _selectedCategory = widget.transaction.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Show category selection bottom sheet
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: _isIncome
                      ? const Color(0xFF7CB342)
                      : const Color(0xFFFF6F00),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select ${_isIncome ? "Income" : "Expense"} Category',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _isIncome
                    ? CategoryManager.incomeCategories.length
                    : CategoryManager.expenseCategories.length,
                itemBuilder: (context, index) {
                  final categoryNames = _isIncome
                      ? CategoryManager.incomeCategories.keys.toList()
                      : CategoryManager.expenseCategories.keys.toList();
                  final category = categoryNames[index];

                  final isSelected = _selectedCategory == category;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (_isIncome
                                    ? const Color(0xFF7CB342)
                                    : const Color(0xFFFF6F00))
                                .withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (_isIncome
                                  ? const Color(0xFF7CB342)
                                  : const Color(0xFFFF6F00))
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CategoryManager.getCategoryIcon(category, _isIncome),
                            size: 32,
                            color: isSelected
                                ? (_isIncome
                                    ? const Color(0xFF7CB342)
                                    : const Color(0xFFFF6F00))
                                : CategoryManager.getCategoryColor(category, _isIncome),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? (_isIncome
                                      ? const Color(0xFF7CB342)
                                      : const Color(0xFFFF6F00))
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update transaction and navigate back
  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedTransaction = Transaction(
      id: widget.transaction.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      isIncome: _isIncome,
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final provider = context.read<TransactionProvider>();
    final success = await provider.updateTransaction(updatedTransaction);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction updated successfully'),
          backgroundColor: const Color(0xFF7CB342),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update transaction'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Edit Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Income/Expense Toggle Section
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
                    'Transaction Type',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                                _isIncome = true;
                                _selectedCategory = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _isIncome
                                    ? const Color(0xFF7CB342)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: _isIncome
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      color: _isIncome
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 16,
                                      fontWeight: _isIncome
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
                                _isIncome = false;
                                _selectedCategory = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: !_isIncome
                                    ? const Color(0xFFFF6F00)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: !_isIncome
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: !_isIncome
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 16,
                                      fontWeight: !_isIncome
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    _buildInputLabel('Title', Icons.title),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration(
                        'Enter transaction title',
                        Icons.edit,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Amount Field
                    _buildInputLabel('Amount', Icons.attach_money),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: _buildInputDecoration(
                        'Enter amount',
                        Icons.money,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Selection
                    _buildInputLabel('Category', Icons.category),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCategory == null
                                ? Colors.grey[300]!
                                : (_isIncome
                                    ? const Color(0xFF7CB342)
                                    : const Color(0xFFFF6F00)),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedCategory != null
                                  ? CategoryManager.getCategoryIcon(
                                      _selectedCategory!, _isIncome)
                                  : Icons.category,
                              color: _selectedCategory != null
                                  ? CategoryManager.getCategoryColor(
                                      _selectedCategory!, _isIncome)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedCategory ?? 'Select category',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedCategory != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date Selection
                    _buildInputLabel('Date', Icons.calendar_today),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8E24AA),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event,
                              color: Color(0xFF8E24AA),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat('MMMM d, yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes Field
                    _buildInputLabel('Notes (Optional)', Icons.notes),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: _buildInputDecoration(
                        'Add notes or description',
                        Icons.note_add,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),

                    // Update Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isIncome
                            ? const Color(0xFF7CB342)
                            : const Color(0xFFFF6F00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF1A237E),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF1A237E),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}
