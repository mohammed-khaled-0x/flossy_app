import 'package:flossy/data/models/money_source_model.dart';
import '../../domain/entities/money_source.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../datasources/local/money_source_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource transactionLocalDataSource;
  final MoneySourceLocalDataSource moneySourceLocalDataSource;

  TransactionRepositoryImpl({
    required this.transactionLocalDataSource,
    required this.moneySourceLocalDataSource,
  });

  @override
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
    // Convert our entities to models that Isar understands
    final transactionModel = TransactionModel.fromEntity(transaction);
    final updatedSourceModel = MoneySourceModel.fromEntity(updatedSource);

    // This is the key part: both operations happen inside a single Isar transaction.
    // If one fails, the other is rolled back automatically. Data consistency is guaranteed.
    await transactionLocalDataSource.performAtomicWrite((isar) async {
      await isar.transactionModels.put(transactionModel);
      await isar.moneySourceModels.put(updatedSourceModel);
    });
  }
}
