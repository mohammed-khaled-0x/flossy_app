import 'package:equatable/equatable.dart';

/// يمثل أي مصدر للأموال في التطبيق.
/// يمتدد من Equatable ليسمح بالمقارنة الذكية بين الكائنات.
class MoneySource extends Equatable {
  final int id;
  final String name;
  final double balance;
  final String iconName;
  final SourceType type;

  const MoneySource({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconName,
    required this.type,
  });

  /// <<<--- SECTION ADDED ---
  /// Creates a copy of this MoneySource but with the given fields replaced with the new values.
  /// A professional pattern for working with immutable state.
  MoneySource copyWith({
    int? id,
    String? name,
    double? balance,
    String? iconName,
    SourceType? type,
  }) {
    return MoneySource(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
    );
  }

  /// --- END OF SECTION ---

  @override
  List<Object?> get props => [id, name, balance, iconName, type];
}

/// لتحديد أنواع المصادر المتاحة في التطبيق.
enum SourceType { cash, bankAccount, electronicWallet }
