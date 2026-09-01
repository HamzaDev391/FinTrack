import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_helper.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../transactions/presentation/add_transaction_screen.dart';
import '../../transactions/presentation/edit_transaction_screen.dart';
import '../../transactions/providers/transaction_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('FinTrack')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load dashboard.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(transactionsProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (transactions) {
          final now = DateTime.now();

          final monthlyTransactions = transactions.where((transaction) {
            return transaction.date.year == now.year &&
                transaction.date.month == now.month;
          }).toList();

          final income = monthlyTransactions
              .where((transaction) => transaction.type == 'income')
              .fold<int>(0, (sum, transaction) => sum + transaction.amount);

          final expenses = monthlyTransactions
              .where((transaction) => transaction.type == 'expense')
              .fold<int>(0, (sum, transaction) => sum + transaction.amount);

          final balance = transactions.fold<int>(0, (sum, transaction) {
            if (transaction.type == 'income') {
              return sum + transaction.amount;
            }

            return sum - transaction.amount;
          });

          final recentTransactions = [...transactions]
            ..sort((a, b) => b.date.compareTo(a.date));

          final recent = recentTransactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionsProvider);
              await ref.read(transactionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _BalanceCard(balance: balance),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Income',
                        amount: income,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Expenses',
                        amount: expenses,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigation is already handled by the shell.
                      },
                      child: const Text('Recent'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (recent.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No transactions yet.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Start tracking your finances by adding your first transaction.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddTransactionScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Transaction'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...recent.map((transaction) {
                    final isIncome = transaction.type == 'income';
                    final currencySymbol = getCurrencySymbol(currency);

                    String categoryName = 'Unknown';

                    final categoriesResult = categoriesAsync.valueOrNull;

                    if (categoriesResult != null) {
                      for (final category in categoriesResult) {
                        if (category.id == transaction.categoryId) {
                          categoryName = category.name;
                          break;
                        }
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditTransactionScreen(
                                transactionId: transaction.id,
                              ),
                            ),
                          );
                        },
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
                        subtitle: Text(
                          '$categoryName • ${_formatDate(transaction.date)}',
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'} $currencySymbol ${transaction.amount}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                Text(
                  'This Month',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ProgressRow(
                          label: 'Income',
                          amount: income,
                          total: income + expenses,
                        ),
                        const SizedBox(height: 20),
                        _ProgressRow(
                          label: 'Expenses',
                          amount: expenses,
                          total: income + expenses,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Transaction'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final currencySymbol = getCurrencySymbol(currency);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol $balance',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final int amount;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final currencySymbol = getCurrencySymbol(currency);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '$currencySymbol $amount',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends ConsumerWidget {
  const _ProgressRow({
    required this.label,
    required this.amount,
    required this.total,
  });

  final String label;
  final int amount;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = total == 0 ? 0.0 : amount / total;
    final currency = ref.watch(currencyProvider);
    final currencySymbol = getCurrencySymbol(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$currencySymbol $amount',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
