import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BudgetRepository {
  BudgetRepository(this._database);

  final AppDatabase _database;

  Future<List<Budget>> getAllBudgets() {
    return (_database.select(_database.budgets)..orderBy([
          (budget) =>
              OrderingTerm(expression: budget.year, mode: OrderingMode.desc),
          (budget) =>
              OrderingTerm(expression: budget.month, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<Budget?> getBudgetById(int id) {
    return (_database.select(
      _database.budgets,
    )..where((budget) => budget.id.equals(id))).getSingleOrNull();
  }

  Future<Budget?> getBudgetForCategoryMonth({
    required int categoryId,
    required int month,
    required int year,
  }) {
    return (_database.select(_database.budgets)..where(
          (budget) =>
              budget.categoryId.equals(categoryId) &
              budget.month.equals(month) &
              budget.year.equals(year),
        ))
        .getSingleOrNull();
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
  }) {
    return (_database.update(_database.budgets)
          ..where((budget) => budget.id.equals(id)))
        .write(
          BudgetsCompanion(
            categoryId: Value(categoryId),
            amount: Value(amount),
            month: Value(month),
            year: Value(year),
          ),
        )
        .then((updatedRows) => updatedRows > 0);
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
      (sum, transaction) => sum + transaction.amount,
    );
  }
}
