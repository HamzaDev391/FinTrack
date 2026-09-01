import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TransactionRepository(database);
});

final transactionsProvider = FutureProvider((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final currency = ref.watch(currencyProvider);

  return repository.getAllTransactions(currency);
});

final transactionByIdProvider = FutureProvider.family((
  ref,
  int transactionId,
) async {
  final repository = ref.watch(transactionRepositoryProvider);

  return repository.getTransactionById(transactionId);
});
