// lib/presentation/managers/state/recurring_transactions_state.dart

import 'package:equatable/equatable.dart';
import 'package:flossy/domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionsState extends Equatable {
  const RecurringTransactionsState();

  @override
  List<Object> get props => [];
}

class RecurringTransactionsInitial extends RecurringTransactionsState {}

class RecurringTransactionsLoading extends RecurringTransactionsState {}

class RecurringTransactionsLoaded extends RecurringTransactionsState {
  final List<RecurringTransaction> transactions;

  const RecurringTransactionsLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class RecurringTransactionsError extends RecurringTransactionsState {
  final String message;

  const RecurringTransactionsError(this.message);

  @override
  List<Object> get props => [message];
}
