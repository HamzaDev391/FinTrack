import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/providers/category_providers.dart';
import 'models/transaction_filter.dart';
import '../providers/transaction_providers.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  TransactionFilter _filter = const TransactionFilter();

  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    final filtered = transactions.where((transaction) {
      final query = _filter.searchQuery.toLowerCase();

      // Search by title.
      if (query.isNotEmpty &&
          !transaction.title.toLowerCase().contains(query)) {
        return false;
      }

      // Filter by income/expense.
      if (_filter.type != null && transaction.type != _filter.type) {
        return false;
      }

      // Filter by category.
      if (_filter.categoryId != null &&
          transaction.categoryId != _filter.categoryId) {
        return false;
      }

      // Filter by start date.
      if (_filter.startDate != null) {
        final transactionDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );

        final startDate = DateTime(
          _filter.startDate!.year,
          _filter.startDate!.month,
          _filter.startDate!.day,
        );

        if (transactionDate.isBefore(startDate)) {
          return false;
        }
      }

      // Filter by end date.
      if (_filter.endDate != null) {
        final transactionDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );

        final endDate = DateTime(
          _filter.endDate!.year,
          _filter.endDate!.month,
          _filter.endDate!.day,
        );

        if (transactionDate.isAfter(endDate)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting.
    switch (_filter.sort) {
      case TransactionSort.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;

      case TransactionSort.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;

      case TransactionSort.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;

      case TransactionSort.lowestAmount:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  void _updateFilter(TransactionFilter filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _filter = const TransactionFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Badge(
              isLabelVisible: _filter.hasFilters,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () {
            ref.invalidate(transactionsProvider);
          },
        ),
        data: (transactions) {
          final filteredTransactions = _filterTransactions(transactions);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _filter = _filter.copyWith(searchQuery: '');
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(searchQuery: value.trim());
                    });
                  },
                ),
              ),

              if (_showFilters)
                _FiltersSection(
                  filter: _filter,
                  onChanged: _updateFilter,
                  onClear: _clearFilters,
                ),

              Expanded(
                child: filteredTransactions.isEmpty
                    ? _NoResults(
                        hasFilters: _filter.hasFilters,
                        onClear: _clearFilters,
                        onAdd: () {
                          _openAddTransaction(context);
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(transactionsProvider);

                          await ref.read(transactionsProvider.future);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];

                            final isIncome = transaction.type == 'income';

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                  ),
                                ),
                                title: Text(
                                  transaction.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: _TransactionSubtitle(
                                  categoryId: transaction.categoryId,
                                  date: transaction.date,
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'} '
                                  'Rs. ${transaction.amount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                onTap: () {
                                  _openEditTransaction(context, transaction.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddTransaction(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
  }

  void _openEditTransaction(BuildContext context, int transactionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transactionId: transactionId),
      ),
    );
  }
}

class _FiltersSection extends ConsumerWidget {
  const _FiltersSection({
    required this.filter,
    required this.onChanged,
    required this.onClear,
  });

  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: filter.type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('All')),
                    DropdownMenuItem<String?>(
                      value: 'expense',
                      child: Text('Expense'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'income',
                      child: Text('Income'),
                    ),
                  ],
                  onChanged: (value) {
                    onChanged(
                      filter.copyWith(type: value, clearType: value == null),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const Text('Categories unavailable'),
                  data: (categories) {
                    return DropdownButtonFormField<int?>(
                      initialValue: filter.categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        onChanged(
                          filter.copyWith(
                            categoryId: value,
                            clearCategory: value == null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<TransactionSort>(
            initialValue: filter.sort,
            decoration: const InputDecoration(
              labelText: 'Sort',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TransactionSort.newest,
                child: Text('Newest'),
              ),
              DropdownMenuItem(
                value: TransactionSort.oldest,
                child: Text('Oldest'),
              ),
              DropdownMenuItem(
                value: TransactionSort.highestAmount,
                child: Text('Highest amount'),
              ),
              DropdownMenuItem(
                value: TransactionSort.lowestAmount,
                child: Text('Lowest amount'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(filter.copyWith(sort: value));
              }
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDateRange:
                          filter.startDate != null && filter.endDate != null
                          ? DateTimeRange(
                              start: filter.startDate!,
                              end: filter.endDate!,
                            )
                          : null,
                    );

                    if (range == null) return;

                    onChanged(
                      filter.copyWith(
                        startDate: range.start,
                        endDate: range.end,
                      ),
                    );
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    filter.startDate == null
                        ? 'Date range'
                        : '${filter.startDate!.day}/'
                              '${filter.startDate!.month}/'
                              '${filter.startDate!.year}'
                              ' - '
                              '${filter.endDate!.day}/'
                              '${filter.endDate!.month}/'
                              '${filter.endDate!.year}',
                  ),
                ),
              ),
              if (filter.hasFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear filters',
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionSubtitle extends ConsumerWidget {
  const _TransactionSubtitle({required this.categoryId, required this.date});

  final int categoryId;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => Text('${date.day}/${date.month}/${date.year}'),
      error: (_, _) => Text('${date.day}/${date.month}/${date.year}'),
      data: (categories) {
        String categoryName = 'Unknown category';

        for (final category in categories) {
          if (category.id == categoryId) {
            categoryName = category.name;
            break;
          }
        }

        return Text(
          '$categoryName • '
          '${date.day}/${date.month}/${date.year}',
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.hasFilters,
    required this.onClear,
    required this.onAdd,
  });

  final bool hasFilters;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching transactions.' : 'No transactions yet.',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try changing or clearing your filters.'
                  : 'Start tracking your finances by '
                        'adding your first transaction.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasFilters)
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear Filters'),
              )
            else
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
