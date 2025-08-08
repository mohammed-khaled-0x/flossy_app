// lib/data/repositories/transaction_repository_impl.dart

import 'package:flossy/data/models/money_source_model.dart';
import '../../domain/entities/money_source.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource transactionLocalDataSource;

  TransactionRepositoryImpl({required this.transactionLocalDataSource});

  @override
  @deprecated
  Future<void> addTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    await transactionLocalDataSource.addTransaction(transactionModel);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionModels = await transactionLocalDataSource
        .getAllTransactions();
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
    final expenseModel = TransactionModel.fromEntity(expenseTransaction);
    final incomeModel = TransactionModel.fromEntity(incomeTransaction);

    await transactionLocalDataSource.performAtomicWrite((isar) async {
      // Fetch the source models from the database inside the transaction
      final sourceFrom = await isar.moneySourceModels.get(
        expenseTransaction.sourceId,
      );
      final sourceTo = await isar.moneySourceModels.get(
        incomeTransaction.sourceId,
      );

      if (sourceFrom == null || sourceTo == null) {
        throw Exception("One or both money sources not found during transfer.");
      }

      // Update their balances
      sourceFrom.balance -= expenseTransaction.amount;
      sourceTo.balance += incomeTransaction.amount;

      // Save everything to the database
      await isar.transactionModels.putAll([expenseModel, incomeModel]);
      await isar.moneySourceModels.putAll([sourceFrom, sourceTo]);
    });
  }
}
