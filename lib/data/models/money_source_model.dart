// lib/data/models/money_source_model.dart

import 'package:isar/isar.dart';
import '../../domain/entities/money_source.dart';

part 'money_source_model.g.dart';

@collection
class MoneySourceModel {
  Id id = Isar.autoIncrement;

  late String name;
  late double balance;
  late String iconName;

  @enumerated
  late SourceType type;

  MoneySourceModel();

  factory MoneySourceModel.fromEntity(MoneySource entity) {
    final model = MoneySourceModel()
      ..name = entity.name
      ..balance = entity.balance
      ..iconName = entity.iconName
      ..type = entity.type;

    // --- THE DEFINITIVE FIX IS HERE ---
    // If the entity has a real ID (not the temporary '0'), it means we are
    // updating an existing object. In that case, we MUST set the model's ID
    // so Isar knows which object to overwrite.
    if (entity.id != 0) {
      model.id = entity.id;
    }

    // If entity.id IS 0, we do nothing. We let Isar's `autoIncrement`
    // generate the new, unique ID when `put()` is called.

    return model;
  }

  MoneySource toEntity() {
    return MoneySource(
      id: id,
      name: name,
      balance: balance,
      iconName: iconName,
      type: type,
    );
  }
}
