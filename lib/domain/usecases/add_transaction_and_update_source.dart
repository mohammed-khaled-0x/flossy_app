import '../entities/money_source.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionAndUpdateSource {
  final TransactionRepository repository;

  AddTransactionAndUpdateSource(this.repository);

  /// This use case now returns the saved [Transaction] object,
  /// complete with the final ID assigned by the database.
  Future<Transaction> call(Transaction transaction, MoneySource updatedSource) {
    return repository.addTransactionAndUpdateSource(transaction, updatedSource);
  }
}
