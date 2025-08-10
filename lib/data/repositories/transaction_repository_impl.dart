// lib/data/repositories/transaction_repository_impl.dart

import 'package:flossy/data/models/money_source_model.dart';
import '../../domain/entities/money_source.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource transactionLocalDataSource;

  TransactionRepositoryImpl({
    required this.transactionLocalDataSource,
  });

  @override
  @deprecated
  Future<void> addTransaction(Transaction transaction) async {
    throw UnimplementedError('Use addTransactionAndUpdateSource');
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionModels =
        await transactionLocalDataSource.getAllTransactions();
    return transactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTransactionAndUpdateSource(
    Transaction transaction,
    MoneySource updatedSource,
  ) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    final updatedSourceModel = MoneySourceModel.fromEntity(updatedSource);

    await transactionLocalDataSource.performAtomicWrite((isar) async {
      await isar.transactionModels.put(transactionModel);
      await isar.moneySourceModels.put(updatedSourceModel);
    });
  }

  @override
  Future<void> performInternalTransfer({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
  }) async {
    // This repository's ONLY job is to save what it's given.
    // The calculation of balances is now correctly handled in the UseCase.
    final expenseModel = TransactionModel.fromEntity(expenseTransaction);
    final incomeModel = TransactionModel.fromEntity(incomeTransaction);

    await transactionLocalDataSource.performAtomicWrite((isar) async {
      // Fetch the sources to be updated
      final fromSourceModel =
          await isar.moneySourceModels.get(expenseTransaction.sourceId);
      final toSourceModel =
          await isar.moneySourceModels.get(incomeTransaction.sourceId);

      if (fromSourceModel == null || toSourceModel == null) {
        throw Exception('Source or destination for transfer not found.');
      }

      // Update their balances
      fromSourceModel.balance -= expenseTransaction.amount;
      toSourceModel.balance += incomeTransaction.amount;

      // Save everything atomically
      await isar.transactionModels.putAll([expenseModel, incomeModel]);
      await isar.moneySourceModels.putAll([fromSourceModel, toSourceModel]);
    });
  }
}
