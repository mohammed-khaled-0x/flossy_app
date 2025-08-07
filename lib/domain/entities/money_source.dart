import 'package:flutter/foundation.dart'; // نحتاجها لـ @required

/// يمثل أي مصدر للأموال في التطبيق.
/// هذا هو الكيان النقي الذي لا يعتمد على أي تفاصيل خارجية.
class MoneySource {
  final String id;
  final String name;
  final double balance;
  final String iconName; // اسم الأيقونة التي سنعرضها (مثلاً: 'cash', 'bank')
  final SourceType type;

  MoneySource({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconName,
    required this.type,
  });
}

/// لتحديد أنواع المصادر المتاحة في التطبيق.
enum SourceType { cash, bankAccount, electronicWallet }
