import '../entities/money_source.dart';
import '../repositories/money_source_repository.dart';

/// حالة استخدام (Use Case) مسؤولة عن تحديث مصدر أموال موجود.
class UpdateMoneySource {
  final MoneySourceRepository repository;

  UpdateMoneySource(this.repository);

  /// الدالة التي يتم استدعاؤها لتنفيذ حالة الاستخدام.
  /// تستقبل كائن [MoneySource] المحدث.
  Future<void> call(MoneySource moneySource) {
    return repository.updateMoneySource(moneySource);
  }
}
