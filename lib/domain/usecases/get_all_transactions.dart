import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// حالة الاستخدام الخاصة بجلب كل المعاملات.
class GetAllTransactions {
  final TransactionRepository repository;

  GetAllTransactions(this.repository);

  Future<List<Transaction>> call() async {
    return await repository.getAllTransactions();
  }
}
