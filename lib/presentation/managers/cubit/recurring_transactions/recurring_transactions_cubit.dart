// lib/presentation/managers/cubit/recurring_transactions/recurring_transactions_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/domain/usecases/add_recurring_transaction.dart';
import 'package:flossy/domain/usecases/get_all_recurring_transactions.dart';
import 'package:flossy/domain/usecases/log_recurring_payment.dart';
import 'package:flossy/domain/usecases/update_recurring_transaction.dart';
import 'package:flossy/presentation/managers/state/recurring_transactions_state.dart';

class RecurringTransactionsCubit extends Cubit<RecurringTransactionsState> {
  final GetAllRecurringTransactions _getAllRecurringTransactions;
  final AddRecurringTransaction _addRecurringTransaction;
  final LogRecurringPayment _logRecurringPayment;
  final UpdateRecurringTransaction _updateRecurringTransaction;

  RecurringTransactionsCubit({
    required GetAllRecurringTransactions getAllRecurringTransactions,
    required AddRecurringTransaction addRecurringTransaction,
    required LogRecurringPayment logRecurringPayment,
    required UpdateRecurringTransaction updateRecurringTransaction,
  })  : _getAllRecurringTransactions = getAllRecurringTransactions,
        _addRecurringTransaction = addRecurringTransaction,
        _logRecurringPayment = logRecurringPayment,
        _updateRecurringTransaction = updateRecurringTransaction,
        super(RecurringTransactionsInitial());

  Future<void> fetchRecurringTransactions() async {
    try {
      emit(RecurringTransactionsLoading());
      final transactions = await _getAllRecurringTransactions();
      // Sort by next due date, earliest first
      transactions.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      emit(RecurringTransactionsLoaded(transactions));
    } catch (e) {
      emit(RecurringTransactionsError(e.toString()));
    }
  }

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      await _addRecurringTransaction(transaction);
      // Refresh the list to show the new transaction
      await fetchRecurringTransactions();
    } catch (e) {
      // Optionally, emit a specific error state for adding
      emit(RecurringTransactionsError(
          "Failed to add transaction: ${e.toString()}"));
    }
  }

  Future<void> logPayment(RecurringTransaction transaction) async {
    try {
      // No need to emit loading, it should be fast.
      await _logRecurringPayment(transaction);
      // We need to fetch all lists again because a regular transaction was added
      // and a recurring one was updated.
      await fetchRecurringTransactions();
    } catch (e) {
      emit(
          RecurringTransactionsError("Failed to log payment: ${e.toString()}"));
    }
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    try {
      await _updateRecurringTransaction(transaction);
      await fetchRecurringTransactions();
    } catch (e) {
      emit(RecurringTransactionsError(
          "Failed to update transaction: ${e.toString()}"));
    }
  }
}
