// lib/presentation/managers/cubit/transactions_cubit.dart

// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction_and_update_source.dart';
import '../../../domain/usecases/get_all_money_sources.dart';
import '../../../domain/usecases/get_all_transactions.dart';

// Presentation Layer
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  // Use cases this cubit depends on
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransactionAndUpdateSource addTransactionAndUpdateSourceUseCase;
  final GetAllMoneySources getAllMoneySourcesUseCase;

  // Other cubits this cubit communicates with
  final MoneySourcesCubit moneySourcesCubit;

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionAndUpdateSourceUseCase,
    required this.getAllMoneySourcesUseCase,
    required this.moneySourcesCubit,
  }) : super(TransactionsInitial());

  Future<void> fetchAllTransactions() async {
    emit(TransactionsLoading());
    try {
      final transactions = await getAllTransactionsUseCase();
      // Sort transactions by date descending (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('فشل تحميل المعاملات: ${e.toString()}'));
    }
  }

  Future<void> addNewTransaction({
    required double amount,
    required TransactionType type,
    required String description,
    required int sourceId,
    String? categoryId,
  }) async {
    final currentState = state;
    if (currentState is! TransactionsLoaded) return;

    try {
      // 1. Get the current source object to calculate the new balance.
      // We use the MoneySourcesCubit's state as the single source of truth for UI data.
      final sourceToUpdate = moneySourcesCubit.getSourceById(sourceId);
      if (sourceToUpdate == null) {
        throw Exception('المصدر المحدد غير موجود.');
      }

      // 2. Calculate the new balance and create the updated source entity.
      final newBalance = (type == TransactionType.income)
          ? sourceToUpdate.balance + amount
          : sourceToUpdate.balance - amount;

      final updatedSource = sourceToUpdate.copyWith(balance: newBalance);

      // 3. Create the new transaction entity.
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        date: DateTime.now(),
        description: description,
        sourceId: sourceId,
        categoryId: categoryId,
      );

      // 4. Call the single, atomic use case to save everything to the database.
      await addTransactionAndUpdateSourceUseCase(newTransaction, updatedSource);

      // 5. Update the UI state instantly and efficiently.
      // No need to re-fetch from the database.

      // Notify MoneySourcesCubit about the change.
      moneySourcesCubit.updateSourceInState(updatedSource);

      // Update this cubit's own state.
      final updatedList = List<Transaction>.from(currentState.transactions)
        ..insert(0, newTransaction); // Insert at the beginning for newest first
      emit(TransactionsLoaded(updatedList));
    } catch (e) {
      emit(TransactionsError('حدث خطأ أثناء إضافة المعاملة: ${e.toString()}'));
      // Optional: Re-fetch state to ensure consistency after an error
      await fetchAllTransactions();
    }
  }
}
