import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Something went wrong:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(category.name),
                  subtitle: Text(category.type),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
