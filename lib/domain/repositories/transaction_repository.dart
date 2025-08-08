import '../entities/transaction.dart';
import '../entities/money_source.dart';

/// "العقد" الذي يحدد العمليات المطلوبة على المعاملات.
abstract class TransactionRepository {
  /// يجلب كل المعاملات المخزنة.
  Future<List<Transaction>> getAllTransactions();

  /// يضيف معاملة جديدة.
  @deprecated
  Future<void> addTransaction(Transaction transaction);
  Future<void> addTransactionAndUpdateSource(
    Transaction transaction,
    MoneySource updatedSource,
  );

  Future<void> performInternalTransfer({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
  });
  // ملاحظة: حاليًا لا نحتاج إلى تحديث أو حذف معاملة في الـ MVP
  // سنضيف هذه الدوال لاحقًا عند الحاجة إليها.
  // Future<void> updateTransaction(Transaction transaction);
  // Future<void> deleteTransaction(String id);
}
