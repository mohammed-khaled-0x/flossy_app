// lib/domain/repositories/recurring_transaction_repository.dart

import 'package:flossy/domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<void> addRecurringTransaction(RecurringTransaction transaction);
  Future<List<RecurringTransaction>> getRecurringTransactions();
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
  Future<void> deleteRecurringTransaction(int id);
}
