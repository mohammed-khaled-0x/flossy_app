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

  // سنستخدم هذه المتغيرات للاستماع للتغييرات في الـ Cubits الأخرى
  late final StreamSubscription moneySourcesSubscription;
  late final StreamSubscription transactionsSubscription;

  DashboardCubit({
    required this.moneySourcesCubit,
    required this.transactionsCubit,
  }) : super(DashboardInitial()) {
    // فور إنشاء الـ Cubit، نبدأ بالاستماع للـ Cubits الأخرى
    moneySourcesSubscription = moneySourcesCubit.stream.listen((state) {
      // إذا تغيرت حالة مصادر الأموال، نعيد حساب بيانات الداشبورد
      if (state is MoneySourcesLoaded) {
        processDashboardData();
      }
    });

    transactionsSubscription = transactionsCubit.stream.listen((state) {
      // إذا تغيرت حالة المعاملات، نعيد حساب بيانات الداشبورد
      if (state is TransactionsLoaded) {
        processDashboardData();
      }
    });
  }

  /// هذه هي الدالة الأساسية التي تجمع البيانات من الـ Cubits الأخرى
  void processDashboardData() {
    // نتأكد أن كلا الـ Cubits في حالة "محمل" ولديهما بيانات
    final moneySourceState = moneySourcesCubit.state;
    final transactionState = transactionsCubit.state;

    if (moneySourceState is MoneySourcesLoaded &&
        transactionState is TransactionsLoaded) {
      emit(DashboardLoading()); // نخبر الواجهة أننا نقوم بالتجميع

      // 1. حساب الرصيد الإجمالي
      final totalBalance = moneySourceState.sources.fold<double>(
        0.0,
        (previousValue, source) => previousValue + source.balance,
      );

      // 2. فرز المعاملات للحصول على الأحدث
      final sortedTransactions = List<Transaction>.from(
        transactionState.transactions,
      )..sort((a, b) => b.date.compareTo(a.date));

      // 3. الحصول على آخر 5 معاملات (أو أقل)
      final recentTransactions = sortedTransactions.take(5).toList();

      // 4. إصدار الحالة النهائية مع كل البيانات المجمعة
      emit(
        DashboardLoaded(
          totalBalance: totalBalance,
          recentTransactions: recentTransactions,
          sources: moneySourceState.sources,
        ),
      );
    } else if (moneySourceState is MoneySourcesError) {
      emit(DashboardError(moneySourceState.message));
    } else if (transactionState is TransactionsError) {
      emit(DashboardError(transactionState.message));
    }
  }

  // دالة أولية لجلب البيانات عند فتح الشاشة
  void loadInitialData() {
    // نطلب من الـ Cubits الأخرى جلب بياناتها
    moneySourcesCubit.fetchAllMoneySources();
    transactionsCubit.fetchAllTransactions();
    // بمجرد أن ينتهوا من الجلب، سيتم تفعيل المستمعين (listeners)
    // ودالة processDashboardData ستعمل تلقائيًا
  }

  @override
  Future<void> close() {
    // من المهم جدًا إلغاء الاشتراكات عند إغلاق الـ Cubit لمنع تسرب الذاكرة
    moneySourcesSubscription.cancel();
    transactionsSubscription.cancel();
    return super.close();
  }
}
