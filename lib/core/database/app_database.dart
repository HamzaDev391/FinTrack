import 'package:drift/drift.dart';

import '../../features/categories/data/default_categories.dart';
import 'database_connection.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(budgets).go();
      await delete(transactions).go();
    });
  }

  Future<void> seedDefaultCategories() async {
    final existingCategories = await select(categories).get();

    if (existingCategories.isNotEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(categories, defaultCategories);
    });
  }
}
