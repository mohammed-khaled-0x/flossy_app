import 'package:isar/isar.dart';
import '../../models/money_source_model.dart';

// نستخدم abstract class لتعريف الواجهة التي يجب أن يلتزم بها مصدر البيانات
abstract class MoneySourceLocalDataSource {
  Future<List<MoneySourceModel>> getAllMoneySources();
  Future<void> addMoneySource(MoneySourceModel source);
  Future<void> updateMoneySource(MoneySourceModel source);
  Future<void> deleteMoneySource(String id);
}

// هذا هو التنفيذ الفعلي للواجهة باستخدام Isar
class MoneySourceLocalDataSourceImpl implements MoneySourceLocalDataSource {
  final Isar isar;

  // نستقبل نسخة من Isar عبر الـ Constructor
  // هذا يسهل عملية الاختبار لاحقًا (Dependency Injection)
  MoneySourceLocalDataSourceImpl({required this.isar});

  @override
  Future<void> addMoneySource(MoneySourceModel source) async {
    // Isar تعمل بشكل متزامن (synchronous) ولكننا نغلفها بـ Future
    // لنلتزم بالواجهة ونكون جاهزين لأي عمليات غير متزامنة في المستقبل
    return await isar.writeTxn(() async {
      await isar.moneySourceModels.put(source);
    });
  }

  @override
  Future<void> deleteMoneySource(String id) async {
    return await isar.writeTxn(() async {
      // نبحث عن الـ isarId الداخلي المطابق للـ id الخاص بنا
      final isarId = await isar.moneySourceModels
          .where()
          .idEqualTo(id)
          .isarIdProperty()
          .findFirst();
      if (isarId != null) {
        await isar.moneySourceModels.delete(isarId);
      }
    });
  }

  @override
  Future<List<MoneySourceModel>> getAllMoneySources() async {
    return await isar.moneySourceModels.where().findAll();
  }

  @override
  Future<void> updateMoneySource(MoneySourceModel source) async {
    // دالة put في Isar تقوم بالإضافة والتحديث تلقائيًا بفضل
    // تعريفنا لـ @Index(unique: true, replace: true) على حقل الـ id
    return await isar.writeTxn(() async {
      await isar.moneySourceModels.put(source);
    });
  }
}
