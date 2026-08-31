import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../data/statistics_data.dart';

final statisticsProvider = FutureProvider.family<StatisticsData, DateTime>((
  ref,
  month,
) async {
  final transactions = await ref.watch(transactionsProvider.future);
  final categories = await ref.watch(categoriesProvider.future);

  return StatisticsData.fromTransactions(
    transactions: transactions,
    categories: categories,
    month: month,
  );
});

final recentMonthlyStatisticsProvider = FutureProvider<List<MonthlyStatistics>>(
  (ref) async {
    final transactions = await ref.watch(transactionsProvider.future);

    final now = DateTime.now();

    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - (5 - index), 1),
    );

    return months.map((month) {
      var income = 0;
      var expenses = 0;

      for (final transaction in transactions) {
        if (transaction.date.year != month.year ||
            transaction.date.month != month.month) {
          continue;
        }

        if (transaction.type == 'income') {
          income += transaction.amount;
        } else if (transaction.type == 'expense') {
          expenses += transaction.amount;
        }
      }

      return MonthlyStatistics(
        month: month,
        income: income,
        expenses: expenses,
      );
    }).toList();
  },
);
