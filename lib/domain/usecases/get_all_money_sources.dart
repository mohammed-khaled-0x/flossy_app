import '../entities/money_source.dart';
import '../repositories/money_source_repository.dart';

/// حالة الاستخدام الخاصة بجلب كل مصادر الأموال.
class GetAllMoneySources {
  final MoneySourceRepository repository;

  GetAllMoneySources(this.repository);

  /// عند استدعاء هذا الكلاس كدالة، سيقوم بتنفيذ المهمة.
  Future<List<MoneySource>> call() async {
    return await repository.getAllMoneySources();
  }
}
