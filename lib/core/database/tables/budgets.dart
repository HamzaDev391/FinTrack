import 'package:drift/drift.dart';

import 'categories.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  IntColumn get amount => integer()();

  IntColumn get month => integer()();

  IntColumn get year => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // One budget per category per calendar month.
  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, month, year},
  ];
}
