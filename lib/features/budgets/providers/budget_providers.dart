import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_initializer.dart';
import '../../../core/database/database_provider.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../data/budget_details.dart';
import '../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseProvider));
});

final budgetsNotifierProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<BudgetDetails>>(
      BudgetsNotifier.new,
    );

class BudgetsNotifier extends AsyncNotifier<List<BudgetDetails>> {
  @override
  Future<List<BudgetDetails>> build() async {
    await ref.watch(databaseInitializerProvider.future);

    // Budget spending depends on expense transactions.
    ref.watch(transactionsProvider);

    final repository = ref.watch(budgetRepositoryProvider);

    return repository.getAllBudgets();
  }

  Future<void> createBudget({
    required int categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.createBudget(
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
    );

    await _reload();
  }

  Future<void> updateBudget({
    required int id,
    required int categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.updateBudget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
    );

    await _reload();
  }

  Future<void> deleteBudget(int id) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.deleteBudget(id);

    await _reload();
  }

  Future<void> refresh() {
    return _reload();
  }

  Future<void> _reload() async {
    final repository = ref.read(budgetRepositoryProvider);

    state = await AsyncValue.guard(repository.getAllBudgets);
  }
}
