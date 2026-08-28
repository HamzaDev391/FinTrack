import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TransactionRepository(database);
});

final transactionsProvider = FutureProvider((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);

  return repository.getAllTransactions();
});
