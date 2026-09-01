import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final AppDatabase _database;

  Future<List<Transaction>> getAllTransactions(String currency) {
    return (_database.select(_database.transactions)
          ..where((transaction) => transaction.currency.equals(currency))
          ..orderBy([
            (transaction) => OrderingTerm(
              expression: transaction.date,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<Transaction?> getTransactionById(int id) {
    return (_database.select(
      _database.transactions,
    )..where((transaction) => transaction.id.equals(id))).getSingleOrNull();
  }

  Future<int> createTransaction({
    required String title,
    required int amount,
    required String currency,
    required String type,
    required int categoryId,
    required DateTime date,
    String? note,
  }) {
    return _database
        .into(_database.transactions)
        .insert(
          TransactionsCompanion.insert(
            title: title,
            amount: amount,
            currency: Value(currency),
            type: type,
            categoryId: categoryId,
            date: date,
            note: Value(note),
          ),
        );
  }

  Future<bool> updateTransaction({
    required int id,
    required String title,
    required int amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? note,
  }) {
    return (_database.update(_database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .write(
          TransactionsCompanion(
            title: Value(title),
            amount: Value(amount),
            type: Value(type),
            categoryId: Value(categoryId),
            date: Value(date),
            note: Value(note),
          ),
        )
        .then((updatedRows) => updatedRows > 0);
  }

  Future<int> deleteTransaction(int id) {
    return (_database.delete(
      _database.transactions,
    )..where((transaction) => transaction.id.equals(id))).go();
  }
}
