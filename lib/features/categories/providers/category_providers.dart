import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_initializer.dart';
import '../../../core/database/database_provider.dart';
import '../data/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return CategoryRepository(database);
});

final categoriesProvider = FutureProvider((ref) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(categoryRepositoryProvider);

  return repository.getAllCategories();
});

final expenseCategoriesProvider = FutureProvider((ref) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(categoryRepositoryProvider);

  return repository.getCategoriesByType('expense');
});

final incomeCategoriesProvider = FutureProvider((ref) async {
  await ref.watch(databaseInitializerProvider.future);

  final repository = ref.watch(categoryRepositoryProvider);

  return repository.getCategoriesByType('income');
});
