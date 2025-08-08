// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_all_money_sources.dart';
import '../../../domain/usecases/get_all_transactions.dart';
import '../../../domain/usecases/update_money_source.dart';

// Presentation Layer
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  // Use cases this cubit depends on
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateMoneySource updateMoneySourceUseCase;
  final GetAllMoneySources getAllMoneySourcesUseCase;

  // Other cubits this cubit communicates with
  final MoneySourcesCubit moneySourcesCubit;

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateMoneySourceUseCase,
    required this.getAllMoneySourcesUseCase,
    required this.moneySourcesCubit,
  }) : super(TransactionsInitial());

  Future<void> fetchAllTransactions() async {
    emit(TransactionsLoading());
    try {
      final transactions = await getAllTransactionsUseCase();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('فشل تحميل المعاملات: ${e.toString()}'));
    }
  }

  Future<void> addNewTransaction({
    required double amount,
    required TransactionType type,
    required String description,
    required String sourceId,
    String? categoryId,
  }) async {
    // Ensure we have a loaded state to update from.
    final currentState = state;
    if (currentState is! TransactionsLoaded) return;

    try {
      // 1. Create the new transaction entity
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        date: DateTime.now(),
        description: description,
        sourceId: sourceId,
        categoryId: categoryId,
      );

      // --- This part remains the same: calculating and saving the new balance ---
      final sources = await getAllMoneySourcesUseCase();
      final sourceToUpdate = sources.firstWhere((s) => s.id == sourceId);
      final newBalance = (type == TransactionType.income)
          ? sourceToUpdate.balance + amount
          : sourceToUpdate.balance - amount;
      final updatedSource = MoneySource(
        id: sourceToUpdate.id,
        name: sourceToUpdate.name,
        balance: newBalance,
        iconName: sourceToUpdate.iconName,
        type: sourceToUpdate.type,
      );

      // 2. Save both the updated source and the new transaction
      await updateMoneySourceUseCase(updatedSource);
      await addTransactionUseCase(newTransaction);

      // --- This is the new, efficient way to update the UI ---

      // 3. Directly notify MoneySourcesCubit with the updated source data.
      moneySourcesCubit.updateSourceInState(updatedSource);

      // 4. Update this cubit's own state instantly.
      final updatedList = List<Transaction>.from(currentState.transactions)
        ..add(newTransaction);
      emit(TransactionsLoaded(updatedList));
    } catch (e) {
      emit(TransactionsError('حدث خطأ أثناء إضافة المعاملة: ${e.toString()}'));
    }
  }
}
