import 'package:flutter/foundation.dart';

/// يمثل أي معاملة مالية (صرف أو دخل) في التطبيق.
class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;
  final String sourceId; // ID لمصدر الأموال الذي تمت عليه المعاملة
  final String? categoryId; // ID لفئة المعاملة (اختياري للدخل)

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.sourceId,
    this.categoryId,
  });
}

/// لتحديد نوع المعاملة
enum TransactionType {
  expense, // مصروف
  income, // دخل
}
