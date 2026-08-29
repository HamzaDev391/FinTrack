import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load categories.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(categoriesProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      category.type == 'income'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    category.type == 'income' ? 'Income' : 'Expense',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCategoryDialog(
                          context,
                          ref,
                          categoryId: category.id,
                          initialName: category.name,
                          initialType: category.type,
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(
                          context,
                          ref,
                          category.id,
                          category.name,
                        );
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    int? categoryId,
    String? initialName,
    String? initialType,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    String selectedType = initialType ?? 'expense';
    final isEditing = categoryId != null;

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add Category'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a category name.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final repository = ref.read(categoryRepositoryProvider);

                    try {
                      if (isEditing) {
                        await repository.updateCategory(
                          id: categoryId,
                          name: nameController.text.trim(),
                          type: selectedType,
                          icon: selectedType == 'income'
                              ? 'arrow_downward'
                              : 'arrow_upward',
                        );
                      } else {
                        await repository.createCategory(
                          name: nameController.text.trim(),
                          type: selectedType,
                          icon: selectedType == 'income'
                              ? 'arrow_downward'
                              : 'arrow_upward',
                        );
                      }

                      ref.invalidate(categoriesProvider);

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (error) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save category: $error'),
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int categoryId,
    String categoryName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text(
            'Delete "$categoryName"? Existing transactions using this '
            'category may be affected.',
          ),
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

    if (shouldDelete != true) return;

    try {
      final repository = ref.read(categoryRepositoryProvider);

      await repository.deleteCategory(categoryId);

      ref.invalidate(categoriesProvider);
      ref.invalidate(transactionsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"$categoryName" deleted.')));
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: $error')),
      );
    }
  }
}
