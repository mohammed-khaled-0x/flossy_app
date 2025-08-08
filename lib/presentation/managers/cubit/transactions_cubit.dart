// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_all_money_sources.dart'; // <<<--- 1. استيراد جديد
import '../../../domain/usecases/get_all_transactions.dart';
import '../../../domain/usecases/update_money_source.dart'; // <<<--- 2. استيراد جديد

// Presentation Layer
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  // Use cases this cubit depends on
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateMoneySource
  updateMoneySourceUseCase; // <<<--- 3. استبدال الـ Repository بالـ UseCase
  final GetAllMoneySources
  getAllMoneySourcesUseCase; // <<<--- 4. إضافة UseCase لجلب المصادر

  // Other cubits this cubit communicates with
  final MoneySourcesCubit moneySourcesCubit;

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateMoneySourceUseCase, // <<<--- 5. تعديل الـ constructor
    required this.getAllMoneySourcesUseCase, // <<<--- 6. تعديل الـ constructor
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
    // We don't emit a loading state here to provide a smoother user experience.
    // The UI can show a loading indicator on the button itself.
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

      // 2. Get the specific money source that needs to be updated
      // We now use the dedicated use case for this
      final sources = await getAllMoneySourcesUseCase();
      final sourceToUpdate = sources.firstWhere((s) => s.id == sourceId);

      // 3. Calculate the new balance
      final newBalance = (type == TransactionType.income)
          ? sourceToUpdate.balance + amount
          : sourceToUpdate.balance - amount;

      // 4. Create the updated money source entity
      final updatedSource = MoneySource(
        id: sourceToUpdate.id,
        name: sourceToUpdate.name,
        balance: newBalance,
        iconName: sourceToUpdate.iconName,
        type: sourceToUpdate.type,
      );

      // 5. Execute both operations: update source and add transaction
      // This can be wrapped in a transaction at the repository level if needed for atomicity.
      await updateMoneySourceUseCase(updatedSource);
      await addTransactionUseCase(newTransaction);

      // 6. Refresh the data in both relevant cubits to update the UI
      await fetchAllTransactions();
      await moneySourcesCubit.fetchAllMoneySources();
    } catch (e) {
      // It's better to emit an error state so the UI can react, e.g., show a snackbar.
      emit(TransactionsError('حدث خطأ أثناء إضافة المعاملة: ${e.toString()}'));
      // To recover, we can fetch the latest state again.
      await fetchAllTransactions();
    }
  }
}
