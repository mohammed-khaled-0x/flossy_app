import 'package:isar/isar.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  /// The single, auto-incrementing integer ID from the Isar database.
  Id id = Isar.autoIncrement;

  /// A unique, case-insensitive index prevents duplicate category names
  /// (e.g., 'Groceries' and 'groceries') and speeds up lookups.
  @Index(unique: true, caseSensitive: false)
  late String name;

  late String iconName; // The name of the icon to display.
  double? budget; // Optional budget for the category.

  /// Isar requires an empty constructor to deserialize objects from the database.
  CategoryModel();

  /// Factory to create a data model from our domain entity.
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel()
      ..id = entity
          .id // The entity's ID must be an int.
      ..name = entity.name
      ..iconName = entity.iconName
      ..budget = entity.budget;
  }

  /// Converts the data model back to a clean domain entity.
  Category toEntity() {
    return Category(id: id, name: name, iconName: iconName, budget: budget);
  }
}
