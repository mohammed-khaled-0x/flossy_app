import '../entities/money_source.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();

  Future<Transaction> addTransactionAndUpdateSource(
    Transaction transaction,
    MoneySource updatedSource,
  );

  /// Performs an internal transfer.
  /// Now it correctly accepts the source and destination MoneySource objects.
  Future<void> performInternalTransfer({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
    required MoneySource fromSource,
    required MoneySource toSource,
  });

  @deprecated
  Future<void> addTransaction(Transaction transaction);
}
