// lib/data/models/transaction_model.dart

import 'package:isar/isar.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  late TransactionType type;

  @Index()
  late DateTime date;

  late String description;

  @Index()
  late int sourceId;

  @Index()
  late int? categoryId;

  TransactionModel();

  factory TransactionModel.fromEntity(Transaction entity) {
    final model = TransactionModel()
      ..amount = entity.amount
      ..type = entity.type
      ..date = entity.date
      ..description = entity.description
      ..sourceId = entity.sourceId
      ..categoryId = entity.categoryId;

    // --- THE SAME FOOLPROOF FIX ---
    // If the entity has a real ID (not the temporary '0'), it means we are
    // updating an existing object. In that case, we MUST set the model's ID.
    if (entity.id != 0) {
      model.id = entity.id;
    }
    // If entity.id IS 0, we let Isar's `autoIncrement` generate the new ID.

    return model;
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      type: type,
      date: date,
      description: description,
      sourceId: sourceId,
      categoryId: categoryId,
    );
  }
}
