import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._database);

  final AppDatabase _database;

  Future<List<Category>> getAllCategories() {
    return _database.select(_database.categories).get();
  }

  Future<List<Category>> getCategoriesByType(String type) {
    return (_database.select(
      _database.categories,
    )..where((category) => category.type.equals(type))).get();
  }

  Future<int> createCategory({
    required String name,
    required String type,
    required String icon,
    bool isDefault = false,
  }) {
    return _database
        .into(_database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            type: type,
            icon: icon,
            isDefault: Value(isDefault),
          ),
        );
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required String type,
    required String icon,
  }) {
    return (_database.update(_database.categories)
          ..where((category) => category.id.equals(id)))
        .write(
          CategoriesCompanion(
            name: Value(name),
            type: Value(type),
            icon: Value(icon),
          ),
        )
        .then((updatedRows) => updatedRows > 0);
  }

  Future<int> deleteCategory(int id) {
    return (_database.delete(
      _database.categories,
    )..where((category) => category.id.equals(id))).go();
  }

  Future<int> getTransactionCount(int categoryId) {
    return (_database.select(_database.transactions)
          ..where((transaction) => transaction.categoryId.equals(categoryId)))
        .get()
        .then((transactions) => transactions.length);
  }
}
