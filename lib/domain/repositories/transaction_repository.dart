import '../entities/transaction.dart';

/// "العقد" الذي يحدد العمليات المطلوبة على المعاملات.
abstract class TransactionRepository {
  /// يجلب كل المعاملات المخزنة.
  Future<List<Transaction>> getAllTransactions();

  /// يضيف معاملة جديدة.
  Future<void> addTransaction(Transaction transaction);

  // ملاحظة: حاليًا لا نحتاج إلى تحديث أو حذف معاملة في الـ MVP
  // سنضيف هذه الدوال لاحقًا عند الحاجة إليها.
  // Future<void> updateTransaction(Transaction transaction);
  // Future<void> deleteTransaction(String id);
}
