import '../entities/money_source.dart';
import '../entities/transaction.dart';
import '../entities/category.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();

  Future<void> addTransactionAndUpdateSource(
    Transaction transaction,
    MoneySource updatedSource,
  );

  /// Performs an internal transfer.
  /// Now it correctly accepts the source and destination MoneySource objects.
  Future<void> performInternalTransfer({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
  });

  @deprecated
  Future<void> addTransaction(Transaction transaction);

  Future<List<Category>> getAllCategories();
}
