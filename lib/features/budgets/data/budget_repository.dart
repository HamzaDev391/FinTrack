import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'budget_details.dart';

class BudgetRepository {
  BudgetRepository(this._database);

  final AppDatabase _database;

  Future<List<BudgetDetails>> getAllBudgets() async {
    final budgets =
        await (_database.select(_database.budgets)..orderBy([
              (budget) => OrderingTerm.desc(budget.year),
              (budget) => OrderingTerm.desc(budget.month),
            ]))
            .get();

    if (budgets.isEmpty) {
      return const [];
    }

    final categories = await _database.select(_database.categories).get();

    final categoryNames = <int, String>{
      for (final category in categories) category.id: category.name,
    };

    final result = <BudgetDetails>[];

    for (final budget in budgets) {
      final spent = await getCategorySpending(
        categoryId: budget.categoryId,
        month: budget.month,
        year: budget.year,
      );

      result.add(
        BudgetDetails(
          budget: budget,
          categoryName: categoryNames[budget.categoryId] ?? 'Unknown',
          spent: spent,
        ),
      );
    }

    return result;
  }

  Future<int> createBudget({
    required int categoryId,
    required int amount,
    required int month,
    required int year,
  }) {
    return _database
        .into(_database.budgets)
        .insert(
          BudgetsCompanion.insert(
            categoryId: categoryId,
            amount: amount,
            month: month,
            year: year,
          ),
        );
  }

  Future<bool> updateBudget({
    required int id,
    required int categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    final updatedRows =
        await (_database.update(
          _database.budgets,
        )..where((budget) => budget.id.equals(id))).write(
          BudgetsCompanion(
            categoryId: Value(categoryId),
            amount: Value(amount),
            month: Value(month),
            year: Value(year),
          ),
        );

    return updatedRows > 0;
  }

  Future<int> deleteBudget(int id) {
    return (_database.delete(
      _database.budgets,
    )..where((budget) => budget.id.equals(id))).go();
  }

  Future<int> getCategorySpending({
    required int categoryId,
    required int month,
    required int year,
  }) async {
    final transactions =
        await (_database.select(_database.transactions)..where(
              (transaction) =>
                  transaction.categoryId.equals(categoryId) &
                  transaction.type.equals('expense') &
                  transaction.date.year.equals(year) &
                  transaction.date.month.equals(month),
            ))
            .get();

    return transactions.fold<int>(
      0,
      (total, transaction) => total + transaction.amount,
    );
  }
}
