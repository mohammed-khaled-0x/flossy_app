import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_money_sources.dart';
import '../state/money_sources_state.dart';

class MoneySourcesCubit extends Cubit<MoneySourcesState> {
  final GetAllMoneySources getAllMoneySourcesUseCase;
  // سنضيف Use Cases أخرى هنا لاحقًا (مثل Add, Update)

  MoneySourcesCubit({required this.getAllMoneySourcesUseCase})
    : super(MoneySourcesInitial());

  /// دالة لجلب كل مصادر الأموال
  Future<void> fetchAllMoneySources() async {
    // نصدر حالة التحميل أولاً لتظهر للمستخدم دائرة انتظار
    emit(MoneySourcesLoading());
    try {
      // نستدعي حالة الاستخدام لجلب البيانات
      final sources = await getAllMoneySourcesUseCase();
      // عند النجاح، نصدر حالة "محمل" مع البيانات
      emit(MoneySourcesLoaded(sources));
    } catch (e) {
      // عند الفشل، نصدر حالة "خطأ" مع رسالة الخطأ
      emit(MoneySourcesError('فشل تحميل مصادر الأموال: ${e.toString()}'));
    }
  }

  // --- سنضيف دوال أخرى هنا لاحقًا لإضافة وتحديث المصادر ---
}
