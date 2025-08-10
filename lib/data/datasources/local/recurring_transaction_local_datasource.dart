// lib/data/datasources/local/recurring_transaction_local_datasource.dart

import 'package:isar/isar.dart';
import 'package:flossy/data/models/recurring_transaction_model.dart';

abstract class RecurringTransactionLocalDataSource {
  Future<void> addRecurringTransaction(RecurringTransactionModel transaction);
  Future<List<RecurringTransactionModel>> getRecurringTransactions();
  Future<void> updateRecurringTransaction(
      RecurringTransactionModel transaction);
  Future<void> deleteRecurringTransaction(int id);
}

class RecurringTransactionLocalDataSourceImpl
    implements RecurringTransactionLocalDataSource {
  final Isar isar;

  RecurringTransactionLocalDataSourceImpl({required this.isar});

  @override
  Future<void> addRecurringTransaction(
      RecurringTransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(transaction);
      // If there's a category, we need to save the link
      if (transaction.category.value != null) {
        await transaction.category.save();
      }
    });
  }

  @override
  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    final transactions =
        await isar.recurringTransactionModels.where().findAll();
    // Eagerly load the category for each transaction
    for (var tx in transactions) {
      await tx.category.load();
    }
    return transactions;
  }

  @override
  Future<void> updateRecurringTransaction(
      RecurringTransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(transaction);
      if (transaction.category.value != null) {
        await transaction.category.save();
      }
    });
  }

  @override
  Future<void> deleteRecurringTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.delete(id);
    });
  }
}
