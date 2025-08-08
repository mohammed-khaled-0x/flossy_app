// lib/domain/usecases/perform_internal_transfer.dart

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class PerformInternalTransfer {
  final TransactionRepository repository;

  PerformInternalTransfer(this.repository);

  Future<void> call({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
  }) {
    return repository.performInternalTransfer(
      expenseTransaction: expenseTransaction,
      incomeTransaction: incomeTransaction,
    );
  }
}
