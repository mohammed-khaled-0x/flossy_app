import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/money_source.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/state/money_sources_state.dart';
import 'add_edit_money_source_page.dart';

// الصفحة أصبحت أبسط بكثير، مجرد StatelessWidget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // لم نعد بحاجة لـ BlocProvider هنا
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
      // الزر العائم لم يعد بحاجة إلى هذا الملف، سننقله إلى MainPage
      // floatingActionButton: ...
    );
  }
}
