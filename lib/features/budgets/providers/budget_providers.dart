import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_initializer.dart';
import '../../../core/database/database_provider.dart';
import '../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return BudgetRepository(database);
});

final budgetsProvider = FutureProvider((ref) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(budgetRepositoryProvider);

  return repository.getAllBudgets();
});

final budgetByIdProvider = FutureProvider.family((ref, int budgetId) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(budgetRepositoryProvider);

  return repository.getBudgetById(budgetId);
});

final categorySpendingProvider = FutureProvider.family((
  ref,
  ({int categoryId, int month, int year}) params,
) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(budgetRepositoryProvider);

  return repository.getCategorySpending(
    categoryId: params.categoryId,
    month: params.month,
    year: params.year,
  );
});
