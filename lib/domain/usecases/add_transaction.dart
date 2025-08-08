import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// حالة الاستخدام الخاصة بإضافة معاملة جديدة.
class AddTransaction {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  /// الدالة تستقبل الكيان الذي نريد إضافته.
  Future<void> call(Transaction transaction) async {
    // TODO: إضافة منطق لخصم أو زيادة الرصيد من MoneySource
    return await repository.addTransaction(transaction);
  }
}
