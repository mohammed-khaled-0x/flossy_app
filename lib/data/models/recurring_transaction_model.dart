// lib/data/models/recurring_transaction_model.dart

import 'package:isar/isar.dart';
import 'package:flossy/data/models/category_model.dart';
import 'package:flossy/domain/entities/recurring_transaction.dart' as domain;

part 'recurring_transaction_model.g.dart';

// --- Data-Level Enums for Isar ---
// These are defined here so the Isar generator can see them.
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

@collection
class RecurringTransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;
  late String description;

  @Enumerated(EnumType.name)
  late TransactionType type; // Uses the enum defined in THIS file.

  @Enumerated(EnumType.name)
  late RecurrencePeriod period; // Uses the enum defined in THIS file.

  late DateTime nextDueDate;

  @Index()
  late int sourceId;

  late bool isActive;

  final category = IsarLink<CategoryModel>();

  // --- Constructors ---
  RecurringTransactionModel();

  factory RecurringTransactionModel.fromEntity(
      domain.RecurringTransaction entity) {
    return RecurringTransactionModel()
      ..id = entity.id == 0 ? Isar.autoIncrement : entity.id
      ..amount = entity.amount
      ..description = entity.description
      // Convert from domain enum to data enum
      ..type = TransactionType.values.byName(entity.type.name)
      ..period = RecurrencePeriod.values.byName(entity.period.name)
      ..nextDueDate = entity.nextDueDate
      ..sourceId = entity.sourceId
      ..isActive = entity.isActive
      ..category.value = entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null;
  }

  // --- Methods ---
  domain.RecurringTransaction toEntity() {
    return domain.RecurringTransaction(
      id: id,
      amount: amount,
      description: description,
      // Convert from data enum back to domain enum
      type: domain.TransactionType.values.byName(type.name),
      period: domain.RecurrencePeriod.values.byName(period.name),
      nextDueDate: nextDueDate,
      sourceId: sourceId,
      isActive: isActive,
      category: category.value?.toEntity(),
    );
  }
}
