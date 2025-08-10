// lib/domain/entities/recurring_transaction.dart

import 'package:equatable/equatable.dart';
import 'package:flossy/domain/entities/category.dart';

// --- Domain-Level Enums ---
// These belong to the business logic and are independent of the database.
enum RecurrencePeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum TransactionType {
  income,
  expense,
}

class RecurringTransaction extends Equatable {
  final int id;
  final double amount;
  final String description;
  final TransactionType type;
  final RecurrencePeriod period;
  final DateTime nextDueDate;
  final int sourceId;
  final Category? category;
  final bool isActive;

  const RecurringTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.period,
    required this.nextDueDate,
    required this.sourceId,
    this.category,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        type,
        period,
        nextDueDate,
        sourceId,
        category,
        isActive,
      ];

  RecurringTransaction copyWith({
    int? id,
    double? amount,
    String? description,
    TransactionType? type,
    RecurrencePeriod? period,
    DateTime? nextDueDate,
    int? sourceId,
    Category? category,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      period: period ?? this.period,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      sourceId: sourceId ?? this.sourceId,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }
}
