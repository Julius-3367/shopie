import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../utils/currency_manager.dart';
import '../utils/category_manager.dart';
import 'add_transaction_screen.dart';
import 'summary_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen with bottom navigation bar
/// Manages navigation between Home, Summary, and Settings screens
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load transactions when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreenContent(),
          SummaryScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
              tooltip: 'Add Transaction',
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Home screen content with search and filter
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filter states
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterCategory;
  bool? _filterIsIncome;
  
  // Sort states
  String _sortBy = 'date'; // date, amount, category, title
  bool _sortAscending = false; // false = descending (newest first)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _filterStartDate = null;
      _filterEndDate = null;
      _filterCategory = null;
      _filterIsIncome = null;
    });
  }

  void _showSortOptions() {
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
            const Text(
              'Sort Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Date', 'date', Icons.calendar_today),
            _buildSortOption('Amount', 'amount', Icons.attach_money),
            _buildSortOption('Title', 'title', Icons.title),
            _buildSortOption('Category', 'category', Icons.category),
            const Divider(height: 24),
            SwitchListTile(
              title: const Text('Ascending Order'),
              subtitle: Text(_sortAscending ? 'Oldest/Lowest first' : 'Newest/Highest first'),
              value: _sortAscending,
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF7CB342)) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        initialStartDate: _filterStartDate,
        initialEndDate: _filterEndDate,
        initialCategory: _filterCategory,
        initialIsIncome: _filterIsIncome,
        onApply: (startDate, endDate, category, isIncome) {
          setState(() {
            _filterStartDate = startDate;
            _filterEndDate = endDate;
            _filterCategory = category;
            _filterIsIncome = isIncome;
          });
        },
        onClear: _clearFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text(
                'Shopie',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            tooltip: _showSearch ? 'Close Search' : 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                tooltip: 'Filter',
              ),
              if (_filterStartDate != null ||
                  _filterEndDate != null ||
                  _filterCategory != null ||
                  _filterIsIncome != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Get all transactions
          var transactions = provider.transactions;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            transactions = transactions.where((transaction) {
              return transaction.title.toLowerCase().contains(_searchQuery) ||
                     (transaction.category?.toLowerCase().contains(_searchQuery) ?? false) ||
                     transaction.amount.toString().contains(_searchQuery);
            }).toList();
          }

          // Apply date range filter
          if (_filterStartDate != null) {
            transactions = transactions.where((t) {
              return t.date.isAfter(_filterStartDate!.subtract(const Duration(days: 1)));
            }).toList();
          }
          if (_filterEndDate != null) {
            transactions = transactions.where((t) {
              return t.date.isBefore(_filterEndDate!.add(const Duration(days: 1)));
            }).toList();
          }

          // Apply category filter
          if (_filterCategory != null) {
            transactions = transactions.where((t) => t.category == _filterCategory).toList();
          }

          // Apply income/expense filter
          if (_filterIsIncome != null) {
            transactions = transactions.where((t) => t.isIncome == _filterIsIncome).toList();
          }

          // Apply sorting
          transactions = _sortTransactions(transactions);

          // Calculate filtered totals
          final filteredIncome = transactions
              .where((t) => t.isIncome)
              .fold(0.0, (sum, t) => sum + t.amount);
          final filteredExpense = transactions
              .where((t) => !t.isIncome)
              .fold(0.0, (sum, t) => sum + t.amount);
          final filteredBalance = filteredIncome - filteredExpense;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTransactions();
            },
            color: Theme.of(context).colorScheme.secondary,
            child: CustomScrollView(
              slivers: [
                // Balance Summary Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Main Balance Card
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildBalanceCard(
                            context,
                            'Current Balance',
                            filteredBalance,
                            Theme.of(context).colorScheme.secondary,
                            Icons.account_balance_wallet,
                          ),
                        ),
                        // Income and Expense Cards
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 30,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Income',
                                  filteredIncome,
                                  const Color(0xFF7CB342),
                                  Icons.arrow_downward,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  'Expense',
                                  filteredExpense,
                                  const Color(0xFFFF6F00),
                                  Icons.arrow_upward,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Filter Badge
                if (_searchQuery.isNotEmpty ||
                    _filterStartDate != null ||
                    _filterEndDate != null ||
                    _filterCategory != null ||
                    _filterIsIncome != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Chip(
                        avatar: const Icon(Icons.filter_alt, size: 18),
                        label: Text(
                          '${transactions.length} filtered results',
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: _clearFilters,
                      ),
                    ),
                  ),

                // Transaction List or Empty State
                transactions.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(),
                      )
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TransactionList(transactions: transactions),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyManager.formatAmount(amount),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap the + button to add your first transaction',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Transaction> _sortTransactions(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    
    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) => _sortAscending 
            ? a.date.compareTo(b.date) 
            : b.date.compareTo(a.date));
        break;
      case 'amount':
        sorted.sort((a, b) => _sortAscending 
            ? a.amount.compareTo(b.amount) 
            : b.amount.compareTo(a.amount));
        break;
      case 'title':
        sorted.sort((a, b) => _sortAscending 
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase()) 
            : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case 'category':
        sorted.sort((a, b) {
          final catA = a.category ?? '';
          final catB = b.category ?? '';
          return _sortAscending 
              ? catA.compareTo(catB) 
              : catB.compareTo(catA);
        });
        break;
    }
    
    return sorted;
  }
}

/// Filter dialog for transactions
class FilterDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialCategory;
  final bool? initialIsIncome;
  final Function(DateTime?, DateTime?, String?, bool?) onApply;
  final VoidCallback onClear;

  const FilterDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategory,
    this.initialIsIncome,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _category;
  bool? _isIncome;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _category = widget.initialCategory;
    _isIncome = widget.initialIsIncome;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Transactions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Filter
            const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _isIncome == null,
                  onSelected: (selected) {
                    setState(() => _isIncome = null);
                  },
                ),
                FilterChip(
                  label: const Text('Income'),
                  selected: _isIncome == true,
                  onSelected: (selected) {
                    setState(() => _isIncome = true);
                  },
                ),
                FilterChip(
                  label: const Text('Expense'),
                  selected: _isIncome == false,
                  onSelected: (selected) {
                    setState(() => _isIncome = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Range Filter
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_startDate == null ? 'Start' : '${_startDate!.day}/${_startDate!.month}'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_endDate == null ? 'End' : '${_endDate!.day}/${_endDate!.month}'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClear();
            Navigator.pop(context);
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate, _category, _isIncome);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
