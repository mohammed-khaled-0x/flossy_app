import 'package:isar/isar.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  TransactionModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late double amount;

  @enumerated
  late TransactionType type;

  late DateTime date;

  late String description;

  // لفهرسة هذا الحقل لتسريع عمليات البحث والفلترة حسب المصدر
  @Index()
  late int sourceId;

  // لفهرسة هذا الحقل لتسريع عمليات البحث والفلترة حسب الفئة
  @Index()
  String? categoryId;

  // --- دوال التحويل ---
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

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel()
      ..id = entity.id
      ..amount = entity.amount
      ..type = entity.type
      ..date = entity.date
      ..description = entity.description
      ..sourceId = entity.sourceId
      ..categoryId = entity.categoryId;
  }
}
