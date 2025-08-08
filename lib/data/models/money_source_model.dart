// lib/data/models/money_source_model.dart

import 'package:isar/isar.dart';
import '../../domain/entities/money_source.dart';

part 'money_source_model.g.dart';

@collection
class MoneySourceModel {
  MoneySourceModel();

  // Isar uses Id type for auto-incrementing primary keys.
  // This will be our SINGLE source of truth for the ID.
  Id id = Isar.autoIncrement;

  late String name;
  late double balance;
  late String iconName;

  @enumerated
  late SourceType type;

  // Converts the data model (this class) to a clean business entity.
  // The UI layer will only interact with the MoneySource entity.
  MoneySource toEntity() {
    return MoneySource(
      id: id, // We pass the Isar Id directly.
      name: name,
      balance: balance,
      iconName: iconName,
      type: type,
    );
  }

  // Creates a data model from a clean business entity.
  // We use this when we need to save or update an entity in the database.
  factory MoneySourceModel.fromEntity(MoneySource entity) {
    return MoneySourceModel()
      ..id = entity
          .id // The entity's ID is now assigned to the Isar ID.
      ..name = entity.name
      ..balance = entity.balance
      ..iconName = entity.iconName
      ..type = entity.type;
  }
}
