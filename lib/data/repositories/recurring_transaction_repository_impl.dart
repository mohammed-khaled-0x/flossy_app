// lib/data/repositories/recurring_transaction_repository_impl.dart

import 'package:flossy/data/datasources/local/recurring_transaction_local_datasource.dart';
import 'package:flossy/data/models/recurring_transaction_model.dart';
import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/domain/repositories/recurring_transaction_repository.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final RecurringTransactionLocalDataSource localDataSource;

  RecurringTransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    final model = RecurringTransactionModel.fromEntity(transaction);
    await localDataSource.addRecurringTransaction(model);
  }

  @override
  Future<void> deleteRecurringTransaction(int id) async {
    await localDataSource.deleteRecurringTransaction(id);
  }

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final models = await localDataSource.getRecurringTransactions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    final model = RecurringTransactionModel.fromEntity(transaction);
    await localDataSource.updateRecurringTransaction(model);
  }
}
