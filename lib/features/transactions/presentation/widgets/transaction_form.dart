import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/providers/category_providers.dart';

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialAmount,
    this.initialType = 'expense',
    this.initialCategoryId,
    this.initialDate,
    this.initialNote,
    this.submitLabel = 'Save Transaction',
  });

  final Future<void> Function({
    required String title,
    required int amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? note,
  })
  onSubmit;

  final String? initialTitle;
  final int? initialAmount;
  final String initialType;
  final int? initialCategoryId;
  final DateTime? initialDate;
  final String? initialNote;
  final String submitLabel;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _type;
  int? _selectedCategoryId;
  late DateTime _selectedDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle ?? '');

    _amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );

    _noteController = TextEditingController(text: widget.initialNote ?? '');

    _type = widget.initialType;
    _selectedCategoryId = widget.initialCategoryId;
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryId = _selectedCategoryId;

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        categoryId: categoryId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save transaction: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = _type == 'expense'
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'expense', child: Text('Expense')),
              DropdownMenuItem(value: 'income', child: Text('Income')),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _type = value;
                      _selectedCategoryId = null;
                    });
                  },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _titleController,
            enabled: !_isSaving,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Lunch',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final title = value?.trim() ?? '';

              if (title.isEmpty) {
                return 'Enter a title.';
              }

              if (title.length > 100) {
                return 'Title is too long.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _amountController,
            enabled: !_isSaving,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'e.g. 500',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(),
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

          categoriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) =>
                Text('Failed to load categories: $error'),
            data: (categories) {
              return DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Select a category.';
                  }

                  return null;
                },
              );
            },
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: _isSaving ? null : _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedDate.day}/'
                      '${_selectedDate.month}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _noteController,
            enabled: !_isSaving,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Optional',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
