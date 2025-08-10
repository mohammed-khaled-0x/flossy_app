// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction_and_update_source.dart';
import '../../../domain/usecases/get_all_money_sources.dart';
import '../../../domain/usecases/get_all_transactions.dart';
import '../../../domain/usecases/perform_internal_transfer.dart';

// Presentation Layer
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  // Use cases this cubit depends on
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransactionAndUpdateSource addTransactionAndUpdateSourceUseCase;
  final GetAllMoneySources getAllMoneySourcesUseCase;
  final PerformInternalTransfer performInternalTransferUseCase;
  // Other cubits this cubit communicates with
  final MoneySourcesCubit moneySourcesCubit;

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionAndUpdateSourceUseCase,
    required this.getAllMoneySourcesUseCase,
    required this.performInternalTransferUseCase,
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
    int? categoryId, // UPDATED: Changed from String? to int?
  }) async {
    final currentState = state;
    if (currentState is! TransactionsLoaded) return;

    try {
      // 1. Get the current source object to calculate the new balance.
      final sourceToUpdate = moneySourcesCubit.getSourceById(sourceId);
      if (sourceToUpdate == null) {
        throw Exception('المصدر المحدد غير موجود.');
      }

      // 2. Calculate the new balance and create the updated source entity.
      final newBalance = (type == TransactionType.income)
          ? sourceToUpdate.balance + amount
          : sourceToUpdate.balance - amount;

      // Note: We need a copyWith method in the MoneySource entity for this to work.
      // We will add it later if it doesn't exist.
      final updatedSource = MoneySource(
        id: sourceToUpdate.id,
        name: sourceToUpdate.name,
        balance: newBalance,
        iconName: sourceToUpdate.iconName,
        type: sourceToUpdate.type,
      );

      // 3. Create the new transaction entity.
      final newTransaction = Transaction(
        id: 0, // UPDATED: Placeholder ID. Isar will assign the real one.
        amount: amount,
        type: type,
        date: DateTime.now(),
        description: description,
        sourceId: sourceId,
        categoryId: categoryId,
      );

      // 4. Call the single, atomic use case to save everything.
      // This use case should return the final transaction object with the correct ID.
      await addTransactionAndUpdateSourceUseCase(
        newTransaction,
        updatedSource,
      );

      // 5. Update the UI state instantly and efficiently.
      moneySourcesCubit.updateSourceInState(updatedSource);

      final updatedList = List<Transaction>.from(currentState.transactions)
        // Use the object returned from the use case, which has the final ID from the DB.
        ..insert(0, newTransaction);
      emit(TransactionsLoaded(updatedList));
    } catch (e) {
      emit(TransactionsError('حدث خطأ أثناء إضافة المعاملة: ${e.toString()}'));
      await fetchAllTransactions();
    }
  }

  Future<void> performTransfer({
    required double amount,
    required int fromSourceId,
    required int toSourceId,
  }) async {
    // It's crucial to get the most up-to-date source objects.
    final fromSource = moneySourcesCubit.getSourceById(fromSourceId);
    final toSource = moneySourcesCubit.getSourceById(toSourceId);

    if (fromSource == null || toSource == null) {
      emit(TransactionsError('لم يتم العثور على أحد مصادر التحويل.'));
      return;
    }

    try {
      await performInternalTransferUseCase(
        amount: amount,
        fromSource: fromSource,
        toSource: toSource,
      );

      // After the use case successfully updates the database, we must re-fetch all data
      // to show the new balances and the two new transaction records.
      await moneySourcesCubit.fetchAllMoneySources();
      await fetchAllTransactions();
    } catch (e) {
      emit(TransactionsError('فشل إتمام عملية التحويل: ${e.toString()}'));
    }
  }
}
