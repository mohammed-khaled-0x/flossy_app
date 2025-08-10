// lib/domain/usecases/get_all_recurring_transactions.dart

import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/domain/repositories/recurring_transaction_repository.dart';

class GetAllRecurringTransactions {
  final RecurringTransactionRepository repository;

  GetAllRecurringTransactions(this.repository);

  Future<List<RecurringTransaction>> call() {
    return repository.getRecurringTransactions();
  }
}
