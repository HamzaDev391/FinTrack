import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_helper.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../data/budget_details.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String monthName(int month) {
  if (month < 1 || month > 12) {
    return 'Unknown month';
  }

  return _monthNames[month - 1];
}

class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    required this.details,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetDetails details;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = details.budget;
    final progress = details.progress.clamp(0.0, 1.0);
    final currency = ref.watch(currencyProvider);
    final currencySymbol = getCurrencySymbol(currency);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    details.categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${monthName(budget.month)} ${budget.year}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget: $currencySymbol ${budget.amount}'),
                Text('Spent: $currencySymbol ${details.spent}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  details.isOverBudget
                      ? 'Over budget: $currencySymbol ${details.spent - budget.amount}'
                      : 'Remaining: $currencySymbol ${details.remaining}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
