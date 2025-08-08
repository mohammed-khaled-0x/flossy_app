// External Packages
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain Layer
import '../../../domain/entities/transaction.dart';

// Presentation Layer
import '../state/dashboard_state.dart';
import '../state/money_sources_state.dart';
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart';
import 'transactions_cubit.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final MoneySourcesCubit moneySourcesCubit;
  final TransactionsCubit transactionsCubit;

  late final StreamSubscription moneySourcesSubscription;
  late final StreamSubscription transactionsSubscription;

  DashboardCubit({
    required this.moneySourcesCubit,
    required this.transactionsCubit,
  }) : super(DashboardInitial());

  /// This method should be called ONCE after the cubit is created.
  void initialize() {
    // We remove the logic from the constructor and put it here.
    // This avoids emitting a state during the build phase.

    // First, listen for future changes.
    moneySourcesSubscription = moneySourcesCubit.stream.listen((_) {
      processDashboardData();
    });

    transactionsSubscription = transactionsCubit.stream.listen((_) {
      processDashboardData();
    });

    // Then, process the initial data.
    processDashboardData();
  }

  /// This is the core function that gathers data from other Cubits.
  void processDashboardData() {
    final moneySourceState = moneySourcesCubit.state;
    final transactionState = transactionsCubit.state;

    if (moneySourceState is MoneySourcesError) {
      emit(DashboardError(moneySourceState.message));
      return;
    }
    if (transactionState is TransactionsError) {
      emit(DashboardError(transactionState.message));
      return;
    }

    if (moneySourceState is MoneySourcesLoaded &&
        transactionState is TransactionsLoaded) {
      final totalBalance = moneySourceState.sources.fold<double>(
        0.0,
        (previousValue, source) => previousValue + source.balance,
      );

      final sortedTransactions = List<Transaction>.from(
        transactionState.transactions,
      )..sort((a, b) => b.date.compareTo(a.date));

      final recentTransactions = sortedTransactions.take(5).toList();

      emit(
        DashboardLoaded(
          totalBalance: totalBalance,
          recentTransactions: recentTransactions,
          sources: moneySourceState.sources,
        ),
      );
    } else {
      emit(DashboardLoading());
    }
  }

  @override
  Future<void> close() {
    moneySourcesSubscription.cancel();
    transactionsSubscription.cancel();
    return super.close();
  }
}
