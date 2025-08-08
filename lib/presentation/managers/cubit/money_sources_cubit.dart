import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; // حزمة لتوليد ID فريد
import '../../../domain/entities/money_source.dart';
import '../../../domain/usecases/add_money_source.dart';
import '../../../domain/usecases/get_all_money_sources.dart';
import '../state/money_sources_state.dart';

class MoneySourcesCubit extends Cubit<MoneySourcesState> {
  final GetAllMoneySources getAllMoneySourcesUseCase;
  final AddMoneySource addMoneySourceUseCase; // 1. إضافة الـ Use Case الجديد

  MoneySourcesCubit({
    required this.getAllMoneySourcesUseCase,
    required this.addMoneySourceUseCase, // 2. إضافته للـ constructor
  }) : super(MoneySourcesInitial());

  /// دالة لجلب كل مصادر الأموال
  Future<void> fetchAllMoneySources() async {
    emit(MoneySourcesLoading());
    try {
      final sources = await getAllMoneySourcesUseCase();
      emit(MoneySourcesLoaded(sources));
    } catch (e) {
      emit(MoneySourcesError('فشل تحميل مصادر الأموال: ${e.toString()}'));
    }
  }

  /// 3. دالة لإضافة مصدر أموال جديد
  Future<void> addNewSource({
    required String name,
    required double balance,
    required String iconName,
    required SourceType type,
  }) async {
    try {
      // إنشاء كيان جديد مع ID فريد باستخدام حزمة uuid
      final newSource = MoneySource(
        id: const Uuid().v4(), // توليد ID فريد من نوع v4
        name: name,
        balance: balance,
        iconName: iconName,
        type: type,
      );

      // استدعاء حالة الاستخدام لإضافة المصدر الجديد
      await addMoneySourceUseCase(newSource);

      // بعد الإضافة بنجاح، نعيد تحميل كل المصادر لتحديث الواجهة
      await fetchAllMoneySources();
    } catch (e) {
      // في حالة حدوث خطأ أثناء الإضافة
      // يمكننا إصدار حالة خطأ خاصة بالإضافة إذا أردنا
      // لكن حاليًا سنكتفي بطباعة الخطأ في الـ console
      print('Error adding new source: ${e.toString()}');
      // يمكن أيضًا إعادة إصدار الحالة السابقة لإبقاء الواجهة كما هي
      // emit(state);
    }
  }
}
