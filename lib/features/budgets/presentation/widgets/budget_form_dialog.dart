import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../settings/providers/settings_providers.dart';
import 'budget_card.dart';

class BudgetFormData {
  const BudgetFormData({
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  final int categoryId;
  final int amount;
  final int month;
  final int year;
}

Future<BudgetFormData?> showBudgetFormDialog({
  required BuildContext context,
  required List<Category> categories,
  Budget? budget,
}) {
  return showDialog<BudgetFormData>(
    context: context,
    builder: (dialogContext) {
      return _BudgetFormDialog(categories: categories, budget: budget);
    },
  );
}

class _BudgetFormDialog extends ConsumerStatefulWidget {
  const _BudgetFormDialog({required this.categories, this.budget});

  final List<Category> categories;
  final Budget? budget;

  @override
  ConsumerState<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends ConsumerState<_BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;

  int? _categoryId;
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();

    final budget = widget.budget;

    _amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );

    _categoryId = budget?.categoryId;
    _month = budget?.month ?? DateTime.now().month;
    _year = budget?.year ?? DateTime.now().year;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budget != null;
    final currency = ref.watch(currencyProvider);
    final currencySymbol = getCurrencySymbol(currency);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select a category.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Budget',
                  prefixText: '$currencySymbol ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = int.tryParse(value?.trim() ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _month,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;

                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(monthName(month)),
                  );
                }),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _month = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _year,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - 1 + index;

                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _year = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      BudgetFormData(
        categoryId: _categoryId!,
        amount: int.parse(_amountController.text.trim()),
        month: _month,
        year: _year,
      ),
    );
  }
}
