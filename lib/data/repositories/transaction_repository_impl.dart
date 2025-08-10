import 'package:flossy/data/models/money_source_model.dart';
import '../../domain/entities/money_source.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../models/transaction_model.dart';
import '../datasources/local/money_source_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource transactionLocalDataSource;
  final MoneySourceLocalDataSource moneySourceLocalDataSource;
  TransactionRepositoryImpl({
    required this.transactionLocalDataSource,
    required this.moneySourceLocalDataSource,
  });

  @override
  @deprecated
  Future<void> addTransaction(Transaction transaction) async {
    throw UnimplementedError(
      'Use addTransactionAndUpdateSource for atomic operations',
    );
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionModels = await transactionLocalDataSource
        .getAllTransactions();
    return transactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction> addTransactionAndUpdateSource(
    Transaction transaction,
    MoneySource updatedSource,
  ) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    final updatedSourceModel = MoneySourceModel.fromEntity(updatedSource);

    int savedTransactionId = 0;

    await transactionLocalDataSource.performAtomicWrite((isar) async {
      savedTransactionId = await isar.transactionModels.put(transactionModel);
      await isar.moneySourceModels.put(updatedSourceModel);
    });

    // CORRECTED: Call copyWith on the 'transaction' entity, not the model.
    return transaction.copyWith(id: savedTransactionId);
  }

  @override
  Future<void> performInternalTransfer({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
    required MoneySource fromSource,
    required MoneySource toSource,
  }) async {
    final expenseModel = TransactionModel.fromEntity(expenseTransaction);
    final incomeModel = TransactionModel.fromEntity(incomeTransaction);

    final fromSourceModel = MoneySourceModel.fromEntity(
      fromSource.copyWith(
        balance: fromSource.balance - expenseTransaction.amount,
      ),
    );
    final toSourceModel = MoneySourceModel.fromEntity(
      toSource.copyWith(balance: toSource.balance + incomeTransaction.amount),
    );

    await transactionLocalDataSource.performAtomicWrite((isar) async {
      await isar.transactionModels.putAll([expenseModel, incomeModel]);
      await isar.moneySourceModels.putAll([fromSourceModel, toSourceModel]);
    });
  }
}

// Helper extensions for creating copies of our immutable entities
extension TransactionCopyWith on Transaction {
  Transaction copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? description,
    int? sourceId,
    int? categoryId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      sourceId: sourceId ?? this.sourceId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

extension MoneySourceCopyWith on MoneySource {
  MoneySource copyWith({
    int? id,
    String? name,
    double? balance,
    String? iconName,
    SourceType? type,
  }) {
    return MoneySource(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
    );
  }
}
