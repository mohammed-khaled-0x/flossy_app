import '../../../domain/entities/money_source.dart';

// الكلاس الأساسي الذي سترث منه كل الحالات
abstract class MoneySourcesState {}

// 1. الحالة الأولية (عندما تبدأ الشاشة)
class MoneySourcesInitial extends MoneySourcesState {}

// 2. حالة التحميل (عندما نكون في انتظار البيانات)
class MoneySourcesLoading extends MoneySourcesState {}

// 3. حالة النجاح (عندما تصل البيانات بنجاح)
class MoneySourcesLoaded extends MoneySourcesState {
  final List<MoneySource> sources;
  MoneySourcesLoaded(this.sources);
}

// 4. حالة الفشل (عند حدوث خطأ)
class MoneySourcesError extends MoneySourcesState {
  final String message;
  MoneySourcesError(this.message);
}
