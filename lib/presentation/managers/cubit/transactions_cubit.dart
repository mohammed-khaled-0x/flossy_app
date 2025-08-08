import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/money_source.dart'; // نحتاجه لتحديث الرصيد
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/money_source_repository.dart'; // نحتاجه لتحديث الرصيد
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_all_transactions.dart';
import '../state/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final GetAllTransactions getAllTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  // نحتاج إلى مستودع مصادر الأموال لنتمكن من تحديث الرصيد
  final MoneySourceRepository moneySourceRepository;

  TransactionsCubit({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.moneySourceRepository,
  }) : super(TransactionsInitial());

  /// دالة لجلب كل المعاملات
  Future<void> fetchAllTransactions() async {
    emit(TransactionsLoading());
    try {
      final transactions = await getAllTransactionsUseCase();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError('فشل تحميل المعاملات: ${e.toString()}'));
    }
  }

  /// دالة لإضافة معاملة جديدة
  Future<void> addNewTransaction({
    required double amount,
    required TransactionType type,
    required String description,
    required String sourceId,
    String? categoryId,
  }) async {
    try {
      // 1. إنشاء كيان المعاملة الجديد
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        date: DateTime.now(),
        description: description,
        sourceId: sourceId,
        categoryId: categoryId,
      );

      // 2. تحديث رصيد مصدر الأموال (الجزء المنطقي المعقد)
      // أولاً، نجلب كل المصادر للعثور على المصدر المطلوب
      final sources = await moneySourceRepository.getAllMoneySources();
      final sourceToUpdate = sources.firstWhere((s) => s.id == sourceId);

      // نحسب الرصيد الجديد
      final newBalance = (type == TransactionType.income)
          ? sourceToUpdate.balance + amount
          : sourceToUpdate.balance - amount;

      // ننشئ نسخة محدّثة من المصدر
      final updatedSource = MoneySource(
        id: sourceToUpdate.id,
        name: sourceToUpdate.name,
        balance: newBalance,
        iconName: sourceToUpdate.iconName,
        type: sourceToUpdate.type,
      );

      // نقوم بتحديث المصدر في قاعدة البيانات
      await moneySourceRepository.updateMoneySource(updatedSource);

      // 3. إضافة المعاملة نفسها إلى قاعدة البيانات
      await addTransactionUseCase(newTransaction);

      // 4. بعد الإضافة بنجاح، نعيد تحميل كل المعاملات لتحديث الواجهة
      await fetchAllTransactions();
    } catch (e) {
      // يمكن إصدار حالة خطأ هنا إذا أردنا عرض رسالة للمستخدم
      print('Error adding new transaction: ${e.toString()}');
    }
  }
}
