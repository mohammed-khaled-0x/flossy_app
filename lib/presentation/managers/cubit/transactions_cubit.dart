import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/money_source_repository.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_all_transactions.dart';
import '../state/transactions_state.dart';
import 'money_sources_cubit.dart'; // 1. استيراد الـ Cubit الآخر

class TransactionsCubit extends Cubit<TransactionsState> {
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final MoneySourceRepository moneySourceRepository;
  final MoneySourcesCubit moneySourcesCubit; // 2. إضافة الـ Cubit الآخر كعضو

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.moneySourceRepository,
    required this.moneySourcesCubit, // 3. إضافته للـ constructor
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
    try {
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        date: DateTime.now(),
        description: description,
        sourceId: sourceId,
        categoryId: categoryId,
      );

      final sources = await moneySourceRepository.getAllMoneySources();
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

      await moneySourceRepository.updateMoneySource(updatedSource);
      await addTransactionUseCase(newTransaction);

      // 4. تحديث كلا الواجهتين
      await fetchAllTransactions(); // تحديث سجل المعاملات (هذه الواجهة)
      await moneySourcesCubit
          .fetchAllMoneySources(); // إخطار الواجهة الأخرى لتحديث نفسها
    } catch (e) {
      print('Error adding new transaction: ${e.toString()}');
    }
  }
}
