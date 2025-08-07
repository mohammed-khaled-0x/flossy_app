import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service_locator.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/state/money_sources_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocProvider لتوفير الـ Cubit للشجرة أسفله (child tree)
    // ونقوم بإنشاء نسخة جديدة منه باستخدام Service Locator (sl)
    return BlocProvider(
      create: (context) => sl<MoneySourcesCubit>()..fetchAllMoneySources(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مصادر فلوسك'),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<MoneySourcesCubit, MoneySourcesState>(
          builder: (context, state) {
            // نعرض واجهة مختلفة بناءً على الحالة الحالية للـ Cubit

            // 1. حالة التحميل
            if (state is MoneySourcesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة الخطأ
            if (state is MoneySourcesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // نعيد محاولة جلب البيانات عند الضغط على الزر
                        context
                            .read<MoneySourcesCubit>()
                            .fetchAllMoneySources();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            // 3. حالة النجاح (البيانات محملة)
            if (state is MoneySourcesLoaded) {
              // في حالة عدم وجود أي مصادر
              if (state.sources.isEmpty) {
                return const Center(
                  child: Text(
                    'لم تقم بإضافة أي مصادر للأموال بعد.\nابدأ بإضافة مصدر جديد!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // في حالة وجود مصادر، نعرضها في قائمة
              return ListView.builder(
                itemCount: state.sources.length,
                itemBuilder: (context, index) {
                  final source = state.sources[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.teal,
                        size: 40,
                      ),
                      title: Text(
                        source.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'الرصيد الحالي',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Text(
                        '${source.balance.toStringAsFixed(2)} ج.م', // "ج.م" هي اختصار جنيه مصري
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            // 4. الحالة الأولية أو أي حالة أخرى غير متوقعة
            return const Center(child: Text('جاري تهيئة الصفحة...'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // هنا سنفتح شاشة إضافة مصدر جديد لاحقًا
          },
          child: const Icon(Icons.add),
          tooltip: 'إضافة مصدر جديد',
        ),
      ),
    );
  }
}
