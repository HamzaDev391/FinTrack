import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_providers.dart';
import '../providers/transaction_providers.dart';
import 'widgets/transaction_form.dart';

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> saveTransaction({
      required String title,
      required int amount,
      required String type,
      required int categoryId,
      required DateTime date,
      String? note,
    }) async {
      final repository = ref.read(transactionRepositoryProvider);
      final currency = ref.read(currencyProvider);

      await repository.createTransaction(
        title: title,
        amount: amount,
        currency: currency,
        type: type,
        categoryId: categoryId,
        date: date,
        note: note,
      );

      ref.invalidate(transactionsProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: TransactionForm(onSubmit: saveTransaction),
    );
  }
}
