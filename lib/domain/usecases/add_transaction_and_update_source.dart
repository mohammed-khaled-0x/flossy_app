// lib/domain/usecases/add_transaction_and_update_source.dart

import '../entities/money_source.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionAndUpdateSource {
  final TransactionRepository repository;

  AddTransactionAndUpdateSource(this.repository);

  Future<void> call(Transaction transaction, MoneySource updatedSource) {
    return repository.addTransactionAndUpdateSource(transaction, updatedSource);
  }
}
