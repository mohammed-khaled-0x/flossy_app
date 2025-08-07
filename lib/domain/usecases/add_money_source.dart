import '../entities/money_source.dart';
import '../repositories/money_source_repository.dart';

/// حالة الاستخدام الخاصة بإضافة مصدر أموال جديد.
class AddMoneySource {
  final MoneySourceRepository repository;

  AddMoneySource(this.repository);

  /// الدالة تستقبل الكيان الذي نريد إضافته.
  Future<void> call(MoneySource source) async {
    return await repository.addMoneySource(source);
  }
}
