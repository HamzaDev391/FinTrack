import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_providers.dart';
import 'widgets/transaction_form.dart';

class EditTransactionScreen extends ConsumerWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionByIdProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          transactionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (transaction) {
              if (transaction == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Delete transaction',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _confirmDelete(context, ref, transaction.id);
                },
              );
            },
          ),
        ],
      ),
      body: transactionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load transaction:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (transaction) {
          if (transaction == null) {
            return const Center(child: Text('Transaction not found.'));
          }

          return TransactionForm(
            initialTitle: transaction.title,
            initialAmount: transaction.amount,
            initialType: transaction.type,
            initialCategoryId: transaction.categoryId,
            initialDate: transaction.date,
            initialNote: transaction.note,
            submitLabel: 'Update Transaction',
            onSubmit:
                ({
                  required title,
                  required amount,
                  required type,
                  required categoryId,
                  required date,
                  note,
                }) async {
                  final repository = ref.read(transactionRepositoryProvider);

                  await repository.updateTransaction(
                    id: transaction.id,
                    title: title,
                    amount: amount,
                    type: type,
                    categoryId: categoryId,
                    date: date,
                    note: note,
                  );

                  ref.invalidate(transactionsProvider);
                  ref.invalidate(transactionByIdProvider(transactionId));
                },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int transactionId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final repository = ref.read(transactionRepositoryProvider);

      await repository.deleteTransaction(transactionId);

      ref.invalidate(transactionsProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $error')),
      );
    }
  }
}
