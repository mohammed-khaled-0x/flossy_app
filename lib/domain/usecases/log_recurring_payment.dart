// lib/domain/usecases/log_recurring_payment.dart

import 'package:flossy/domain/entities/recurring_transaction.dart'
    as domain; // Renamed for clarity
import 'package:flossy/domain/entities/transaction.dart' as regular;
import 'package:flossy/domain/repositories/money_source_repository.dart';
import 'package:flossy/domain/repositories/transaction_repository.dart';
import 'package:flossy/domain/repositories/recurring_transaction_repository.dart';

class LogRecurringPayment {
  final TransactionRepository _transactionRepository;
  final MoneySourceRepository _moneySourceRepository;
  final RecurringTransactionRepository _recurringTransactionRepository;

  LogRecurringPayment(this._transactionRepository, this._moneySourceRepository,
      this._recurringTransactionRepository);

  Future<void> call(domain.RecurringTransaction recurringTx) async {
    // ---- الإصلاح الأول: تمرير categoryId بدلاً من category كامل ----
    // ---- والإصلاح الثالث: تحويل الـ enum بشكل صحيح ----
    final newRegularTransaction = regular.Transaction(
      id: 0,
      amount: recurringTx.amount,
      type: regular.TransactionType.values
          .byName(recurringTx.type.name), // تحويل بالاسم
      description: recurringTx.description,
      date: DateTime.now(),
      sourceId: recurringTx.sourceId,
      categoryId: recurringTx.category?.id, // تمرير الـ ID فقط
    );
    await _transactionRepository.addTransaction(newRegularTransaction);

    // ---- الإصلاح الثاني: هذه الدالة ستعمل الآن بعد التعديلات الأخرى ----
    final source =
        await _moneySourceRepository.getSourceById(recurringTx.sourceId);
    if (source != null) {
      final newBalance = recurringTx.type == domain.TransactionType.income
          ? source.balance + recurringTx.amount
          : source.balance - recurringTx.amount;
      final updatedSource = source.copyWith(balance: newBalance);
      await _moneySourceRepository.updateMoneySource(updatedSource);
    }

    // حساب تاريخ الاستحقاق القادم
    final DateTime nextDueDate =
        _calculateNextDueDate(recurringTx.nextDueDate, recurringTx.period);

    // تحديث الالتزام الدوري بالتاريخ الجديد
    final updatedRecurringTx = recurringTx.copyWith(nextDueDate: nextDueDate);
    await _recurringTransactionRepository
        .updateRecurringTransaction(updatedRecurringTx);
  }

  // هذه الدالة سليمة ولا تحتاج تعديل
  DateTime _calculateNextDueDate(
      DateTime currentDueDate, domain.RecurrencePeriod period) {
    switch (period) {
      case domain.RecurrencePeriod.weekly:
        return DateTime(
            currentDueDate.year, currentDueDate.month, currentDueDate.day + 7);
      case domain.RecurrencePeriod.monthly:
        return DateTime(
            currentDueDate.year, currentDueDate.month + 1, currentDueDate.day);
      case domain.RecurrencePeriod.quarterly:
        return DateTime(
            currentDueDate.year, currentDueDate.month + 3, currentDueDate.day);
      case domain.RecurrencePeriod.yearly:
        return DateTime(
            currentDueDate.year + 1, currentDueDate.month, currentDueDate.day);
    }
  }
}
