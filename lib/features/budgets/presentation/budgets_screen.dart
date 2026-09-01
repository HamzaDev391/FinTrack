import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/budget_details.dart';
import '../providers/budget_providers.dart';
import 'widgets/budget_card.dart';
import 'widgets/budget_form_dialog.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: categoriesAsync.whenOrNull(
        data: (categories) {
          return FloatingActionButton.extended(
            onPressed: () => _addBudget(context, ref, categories),
            icon: const Icon(Icons.add),
            label: const Text('Add Budget'),
          );
        },
      ),
      body: budgetsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return _ErrorState(
            onRetry: () {
              ref.invalidate(budgetsNotifierProvider);
            },
          );
        },
        data: (budgets) {
          if (budgets.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(budgetsNotifierProvider.notifier).refresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: budgets.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final details = budgets[index];

                return BudgetCard(
                  key: ValueKey(details.budget.id),
                  details: details,
                  onEdit: () => _editBudget(context, ref, details),
                  onDelete: () => _deleteBudget(context, ref, details),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _addBudget(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) async {
    final formData = await showBudgetFormDialog(
      context: context,
      categories: categories,
    );

    if (formData == null) {
      return;
    }

    try {
      await ref
          .read(budgetsNotifierProvider.notifier)
          .createBudget(
            categoryId: formData.categoryId,
            amount: formData.amount,
            currency: ref.read(currencyProvider),
            month: formData.month,
            year: formData.year,
          );

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Budget created.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showBudgetError(context, error);
    }
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetDetails details,
  ) async {
    final categories = ref.read(expenseCategoriesProvider).valueOrNull;

    if (categories == null) {
      return;
    }

    final formData = await showBudgetFormDialog(
      context: context,
      categories: categories,
      budget: details.budget,
    );

    if (formData == null) {
      return;
    }

    try {
      await ref
          .read(budgetsNotifierProvider.notifier)
          .updateBudget(
            id: details.budget.id,
            categoryId: formData.categoryId,
            amount: formData.amount,
            month: formData.month,
            year: formData.year,
          );

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Budget updated.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showBudgetError(context, error);
    }
  }

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetDetails details,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete budget?'),
          content: Text('Delete the budget for "${details.categoryName}"?'),
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

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(budgetsNotifierProvider.notifier)
          .deleteBudget(details.budget.id);

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Budget deleted.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showBudgetError(context, error);
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static void _showBudgetError(BuildContext context, Object error) {
    final text = error.toString().toLowerCase();

    final message = text.contains('unique') || text.contains('constraint')
        ? 'A budget already exists for this category and month.'
        : 'Failed to save budget.';

    _showMessage(context, message);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 56),
            SizedBox(height: 16),
            Text(
              'No budgets yet.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Create a monthly budget to keep your spending on track.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Failed to load budgets.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
