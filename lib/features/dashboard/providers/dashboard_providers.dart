import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

final dashboardTransactionsProvider = Provider((ref) {
  return ref.watch(transactionsProvider);
});

final dashboardCategoriesProvider = Provider((ref) {
  return ref.watch(categoriesProvider);
});
