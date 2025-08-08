import 'package:flutter/foundation.dart';

/// يمثل فئة لتصنيف المعاملات (مثل: أكل، مواصلات).
class Category {
  final String id;
  final String name;
  final String iconName; // اسم الأيقونة التي تمثل الفئة
  final double? budget; // الميزانية الشهرية المخصصة لهذه الفئة (اختياري)

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.budget,
  });
}
