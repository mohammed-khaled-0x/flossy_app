import '../entities/money_source.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class PerformInternalTransfer {
  final TransactionRepository repository;

  PerformInternalTransfer(this.repository);

  Future<void> call({
    required Transaction expenseTransaction,
    required Transaction incomeTransaction,
    required MoneySource fromSource,
    required MoneySource toSource,
  }) {
    return repository.performInternalTransfer(
      expenseTransaction: expenseTransaction,
      incomeTransaction: incomeTransaction,
      fromSource: fromSource,
      toSource: toSource,
    );
  }
}
