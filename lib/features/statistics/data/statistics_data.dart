import '../../../core/database/app_database.dart';

class StatisticsData {
  const StatisticsData({
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.expenseBreakdown,
    required this.categorySpending,
  });

  final DateTime month;
  final int totalIncome;
  final int totalExpenses;
  final List<ExpenseCategoryStatistics> expenseBreakdown;
  final List<CategorySpending> categorySpending;

  factory StatisticsData.fromTransactions({
    required List<Transaction> transactions,
    required List<Category> categories,
    required DateTime month,
  }) {
    final monthlyTransactions = transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    });

    var totalIncome = 0;
    var totalExpenses = 0;

    final spendingByCategory = <int, int>{};

    for (final transaction in monthlyTransactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
        continue;
      }

      if (transaction.type == 'expense') {
        totalExpenses += transaction.amount;

        spendingByCategory.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final categoryNames = <int, String>{
      for (final category in categories) category.id: category.name,
    };

    final categorySpending =
        spendingByCategory.entries
            .map(
              (entry) => CategorySpending(
                categoryId: entry.key,
                categoryName: categoryNames[entry.key] ?? 'Unknown category',
                amount: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final expenseBreakdown = categorySpending
        .map(
          (category) => ExpenseCategoryStatistics(
            categoryId: category.categoryId,
            categoryName: category.categoryName,
            amount: category.amount,
            percentage: totalExpenses == 0
                ? 0
                : category.amount / totalExpenses * 100,
          ),
        )
        .toList();

    return StatisticsData(
      month: month,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      expenseBreakdown: expenseBreakdown,
      categorySpending: categorySpending,
    );
  }
}

class ExpenseCategoryStatistics {
  const ExpenseCategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  final int categoryId;
  final String categoryName;
  final int amount;
  final double percentage;
}

class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
  });

  final int categoryId;
  final String categoryName;
  final int amount;
}

class MonthlyStatistics {
  const MonthlyStatistics({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final DateTime month;
  final int income;
  final int expenses;
}
