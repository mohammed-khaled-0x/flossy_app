import 'package:isar/isar.dart';
import '../../domain/entities/money_source.dart';

// هذا السطر يخبر مولد الكود أن هذا الملف يحتاج إلى معالجة
part 'money_source_model.g.dart';

@collection
class MoneySourceModel {
  // --- START: The Fix ---
  /// منشئ فارغ وغير مسمى، مطلوب بواسطة isar_generator.
  MoneySourceModel();
  // --- END: The Fix ---

  // Isar تستخدم Id بدلاً من int لضمان التفرد والأداء العالي
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  late double balance;
  late String iconName;

  @enumerated
  late SourceType type;

  // دالة لتحويل النموذج (Model) إلى الكيان (Entity) النقي
  MoneySource toEntity() {
    return MoneySource(
      id: id,
      name: name,
      balance: balance,
      iconName: iconName,
      type: type,
    );
  }

  // دالة لإنشاء النموذج (Model) من الكيان (Entity) النقي
  // نستخدمها عندما نريد حفظ كيان في قاعدة البيانات
  factory MoneySourceModel.fromEntity(MoneySource entity) {
    return MoneySourceModel()
      ..id = entity.id
      ..name = entity.name
      ..balance = entity.balance
      ..iconName = entity.iconName
      ..type = entity.type;
  }
}
