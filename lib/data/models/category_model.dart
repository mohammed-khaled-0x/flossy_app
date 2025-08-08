import 'package:isar/isar.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  late String iconName;
  double? budget;

  // --- دوال التحويل ---
  Category toEntity() {
    return Category(id: id, name: name, iconName: iconName, budget: budget);
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel()
      ..id = entity.id
      ..name = entity.name
      ..iconName = entity.iconName
      ..budget = entity.budget;
  }
}
