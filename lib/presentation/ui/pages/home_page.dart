import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/money_source.dart'; // استيراد الـ enum
import '../../../service_locator.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/state/money_sources_state.dart';
import 'add_edit_money_source_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // الـ HomePage الآن وظيفته فقط هي توفير الـ Cubit
    return BlocProvider(
      create: (context) => sl<MoneySourcesCubit>()..fetchAllMoneySources(),
      child: const _HomePageView(), // نعرض الـ Widget الداخلي الجديد
    );
  }
}

// هذا هو الـ Widget الداخلي الذي يحتوي على الواجهة الفعلية
class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    // الـ `context` هنا هو "ابن" للـ BlocProvider، لذلك يمكنه إيجاد الـ Cubit
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصادر فلوسك'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MoneySourcesCubit, MoneySourcesState>(
        builder: (context, state) {
          if (state is MoneySourcesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoneySourcesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MoneySourcesCubit>().fetchAllMoneySources();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is MoneySourcesLoaded) {
            if (state.sources.isEmpty) {
              return const Center(
                child: Text(
                  'لم تقم بإضافة أي مصادر للأموال بعد.\nابدأ بإضافة مصدر جديد!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.sources.length,
              itemBuilder: (context, index) {
                final source = state.sources[index];

                final Map<SourceType, IconData> iconMap = {
                  SourceType.cash: Icons.money_rounded,
                  SourceType.bankAccount: Icons.account_balance_rounded,
                  SourceType.electronicWallet:
                      Icons.account_balance_wallet_rounded,
                };

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      iconMap[source.type] ?? Icons.help_outline,
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
                      '${source.balance.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        color: source.balance >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('جاري تهيئة الصفحة...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MoneySourcesCubit>(),
                child: const AddEditMoneySourcePage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة مصدر جديد',
      ),
    );
  }
}
