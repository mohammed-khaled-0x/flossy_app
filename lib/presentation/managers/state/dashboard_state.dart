import 'package:equatable/equatable.dart';
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';

/// الكلاس الأساسي الذي سترث منه كل حالات شاشة لوحة التحكم.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

/// الحالة الأولية، عند بدء تشغيل الشاشة لأول مرة.
class DashboardInitial extends DashboardState {}

/// حالة التحميل، عندما يتم جلب البيانات.
class DashboardLoading extends DashboardState {}

/// حالة النجاح، عندما يتم تحميل البيانات بنجاح.
/// هذه الحالة تحمل كل البيانات التي تحتاجها الواجهة لعرضها.
class DashboardLoaded extends DashboardState {
  /// الرصيد الإجمالي للمستخدم (مجموع أرصدة كل المصادر).
  final double totalBalance;

  /// قائمة بآخر 5 معاملات (أو أقل إذا لم يكن هناك 5 معاملات).
  final List<Transaction> recentTransactions;

  /// قائمة بكل مصادر الأموال (قد نحتاجها لعرض شيء ما في المستقبل).
  final List<MoneySource> sources;

  const DashboardLoaded({
    required this.totalBalance,
    required this.recentTransactions,
    required this.sources,
  });

  @override
  List<Object> get props => [totalBalance, recentTransactions, sources];
}

/// حالة الفشل، عند حدوث خطأ أثناء تحميل البيانات.
class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}
