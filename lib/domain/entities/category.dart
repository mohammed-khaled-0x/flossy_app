import 'package:equatable/equatable.dart';

/// Represents a category for classifying transactions (e.g., Food, Transport).
/// Extends Equatable to allow for value-based equality checks.
class Category extends Equatable {
  /// The unique ID of the category. Now an integer to match the database.
  final int id;

  final String name;
  final String iconName; // The name of the icon representing the category
  final double? budget; // Optional monthly budget for this category

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.budget,
  });

  @override
  List<Object?> get props => [id, name, iconName, budget];
}
