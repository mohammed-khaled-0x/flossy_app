import 'package:equatable/equatable.dart';

/// Represents a financial transaction (expense or income) in the app.
/// Extends Equatable to allow for value-based equality checks.
class Transaction extends Equatable {
  /// The unique ID of the transaction. Now an integer to match the database.
  final int id;

  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;

  /// The ID of the money source this transaction belongs to.
  final int sourceId;

  /// The ID of the category this transaction belongs to.
  /// Now an integer to match the Category model's future ID.
  final int? categoryId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.sourceId,
    this.categoryId,
  });

  /// The properties that define the identity of the transaction.
  /// Used by Equatable to compare instances.
  @override
  List<Object?> get props => [
    id,
    amount,
    type,
    date,
    description,
    sourceId,
    categoryId,
  ];
}

/// Defines the type of the transaction.
enum TransactionType {
  expense, // مصروف
  income, // دخل
}
