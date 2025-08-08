import '../../../domain/entities/transaction.dart';

// الكلاس الأساسي الذي سترث منه كل الحالات
abstract class TransactionsState {}

// الحالة الأولية
class TransactionsInitial extends TransactionsState {}

// حالة التحميل
class TransactionsLoading extends TransactionsState {}

// حالة النجاح (عندما تصل قائمة المعاملات)
class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  TransactionsLoaded(this.transactions);
}

// حالة الفشل
class TransactionsError extends TransactionsState {
  final String message;
  TransactionsError(this.message);
}
