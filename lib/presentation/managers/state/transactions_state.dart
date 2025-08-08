import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;

  const TransactionsLoaded(this.transactions);

  // <<<--- THE FINAL, GUARANTEED FIX ---
  // Using the spread operator for the transactions list as well.
  @override
  List<Object> get props => [...transactions];
  // --- END OF CHANGE ---
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object> get props => [message];
}
