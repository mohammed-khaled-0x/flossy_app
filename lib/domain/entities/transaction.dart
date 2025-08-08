import 'package:equatable/equatable.dart';

/// يمثل أي معاملة مالية (صرف أو دخل) في التطبيق.
/// يمتدد من Equatable ليسمح بالمقارنة الذكية بين الكائنات.
class Transaction extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;
  final String sourceId;
  final String? categoryId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.sourceId,
    this.categoryId,
  });

  // نحدد الخصائص التي تعرف "هوية" المعاملة
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

/// لتحديد نوع المعاملة
enum TransactionType {
  expense, // مصروف
  income, // دخل
}
