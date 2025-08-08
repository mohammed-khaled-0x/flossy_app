import 'package:equatable/equatable.dart';
import '../../../domain/entities/money_source.dart';

abstract class MoneySourcesState extends Equatable {
  const MoneySourcesState();

  @override
  List<Object> get props => [];
}

class MoneySourcesInitial extends MoneySourcesState {}

class MoneySourcesLoading extends MoneySourcesState {}

class MoneySourcesLoaded extends MoneySourcesState {
  final List<MoneySource> sources;

  const MoneySourcesLoaded(this.sources);

  // <<<--- THE FINAL, GUARANTEED FIX ---
  // We are now using the spread operator (...) to expand the list.
  // This places each individual MoneySource object into the props list.
  // Equatable will now compare each MoneySource object one by one.
  // Since MoneySource itself is Equatable, this will work perfectly.
  @override
  List<Object> get props => [...sources];
  // --- END OF CHANGE ---
}

class MoneySourcesError extends MoneySourcesState {
  final String message;

  const MoneySourcesError(this.message);

  @override
  List<Object> get props => [message];
}
