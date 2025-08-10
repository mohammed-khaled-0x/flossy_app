// lib/presentation/managers/state/money_sources_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/money_source.dart';

/// The base class for all states related to money sources.
/// It extends Equatable to allow for value-based comparisons.
abstract class MoneySourcesState extends Equatable {
  const MoneySourcesState();

  @override
  List<Object> get props => [];
}

/// The initial state when the feature is first loaded.
class MoneySourcesInitial extends MoneySourcesState {}

/// The state indicating that data is being fetched.
class MoneySourcesLoading extends MoneySourcesState {}

/// The state representing that the money sources were loaded successfully.
class MoneySourcesLoaded extends MoneySourcesState {
  final List<MoneySource> sources;

  const MoneySourcesLoaded(this.sources);

  // This is the crucial part. Equatable will now compare the 'sources' list
  // to determine if the state has actually changed.
  @override
  List<Object> get props => [sources];
}

/// The state representing an error while fetching money sources.
class MoneySourcesError extends MoneySourcesState {
  final String message;

  const MoneySourcesError(this.message);

  @override
  List<Object> get props => [message];
}
