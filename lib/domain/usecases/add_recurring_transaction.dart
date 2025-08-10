// lib/domain/usecases/add_recurring_transaction.dart

import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/domain/repositories/recurring_transaction_repository.dart';

class AddRecurringTransaction {
  final RecurringTransactionRepository repository;

  AddRecurringTransaction(this.repository);

  Future<void> call(RecurringTransaction transaction) {
    return repository.addRecurringTransaction(transaction);
  }
}
