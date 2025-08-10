// lib/domain/usecases/perform_internal_transfer.dart

import '../entities/money_source.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class PerformInternalTransfer {
  final TransactionRepository repository;

  PerformInternalTransfer(this.repository);

  Future<void> call({
    required double amount,
    required MoneySource fromSource,
    required MoneySource toSource,
  }) async {
    final now = DateTime.now();

    // --- THE DEFINITIVE FIX FOR USER-FRIENDLY DESCRIPTIONS ---

    // The EXPENSE transaction (money leaving fromSource)
    // The description should state WHERE the money CAME FROM.
    final expenseTransaction = Transaction(
      id: 0,
      amount: amount,
      type: TransactionType.expense,
      date: now,
      description:
          'تحويل من: ${fromSource.name}', // Example: "Transfer from: My Pocket"
      sourceId: fromSource.id,
      categoryId: null,
    );

    // The INCOME transaction (money arriving at toSource)
    // The description should state WHERE the money IS GOING TO.
    final incomeTransaction = Transaction(
      id: 0,
      amount: amount,
      type: TransactionType.income,
      date: now,
      description:
          'تحويل إلى: ${toSource.name}', // Example: "Transfer to: Vodafone Wallet"
      sourceId: toSource.id,
      categoryId: null,
    );

    await repository.performInternalTransfer(
      expenseTransaction: expenseTransaction,
      incomeTransaction: incomeTransaction,
    );
  }
}
