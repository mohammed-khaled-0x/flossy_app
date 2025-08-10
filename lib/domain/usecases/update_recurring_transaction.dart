// lib/domain/usecases/update_recurring_transaction.dart

import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/domain/repositories/recurring_transaction_repository.dart';

class UpdateRecurringTransaction {
  final RecurringTransactionRepository repository;

  UpdateRecurringTransaction(this.repository);

  Future<void> call(RecurringTransaction transaction) {
    return repository.updateRecurringTransaction(transaction);
  }
}
