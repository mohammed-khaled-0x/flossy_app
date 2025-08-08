import '../entities/money_source.dart';

/// هذا هو "العقد" أو الواجهة التي تحدد العمليات المطلوبة
/// على مصادر الأموال. طبقة الـ Domain لا تهتم بكيفية تنفيذ هذه العمليات،
/// فقط تعلن عن وجودها.
abstract class MoneySourceRepository {
  /// يجلب كل مصادر الأموال المخزنة.
  Future<List<MoneySource>> getAllMoneySources();

  /// يضيف مصدر أموال جديد.
  Future<void> addMoneySource(MoneySource source);

  /// يحدث بيانات مصدر أموال موجود.
  Future<void> updateMoneySource(MoneySource source);

  /// يحذف مصدر أموال باستخدام الـ id الخاص به.
  Future<void> deleteMoneySource(int id);
}
