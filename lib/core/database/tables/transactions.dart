import 'package:drift/drift.dart';

import 'categories.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  IntColumn get amount => integer()();

  TextColumn get currency => text().withDefault(const Constant('PKR'))();

  TextColumn get type => text()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
