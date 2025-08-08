// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';

// Presentation Layer
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/state/money_sources_state.dart';
import 'add_edit_money_source_page.dart';

class MoneySourcesPage extends StatelessWidget {
  const MoneySourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصادر الأموال'),
        actions: [
          // Button to add a new money source
          IconButton(
            icon: const Icon(Icons.add_card_outlined),
            tooltip: 'إضافة مصدر جديد',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditMoneySourcePage(),
                ),
              );
            },
          ),
        ],
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لم تقم بإضافة أي مصادر للأموال بعد.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('ابدأ بإضافة مصدر جديد'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditMoneySourcePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.sources.length,
              itemBuilder: (context, index) {
                final source = state.sources[index];
                return _MoneySourceCard(source: source);
              },
            );
          }

          // Fallback state
          return const Center(child: Text('جاري تهيئة الصفحة...'));
        },
      ),
    );
  }
}

// A dedicated widget for a single money source card.
class _MoneySourceCard extends StatelessWidget {
  const _MoneySourceCard({required this.source});

  final MoneySource source;

  IconData _getIconForSourceType(SourceType type) {
    switch (type) {
      case SourceType.cash:
        return Icons.money_rounded;
      case SourceType.bankAccount:
        return Icons.account_balance_rounded;
      case SourceType.electronicWallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          _getIconForSourceType(source.type),
          color: Theme.of(context).colorScheme.primary,
          size: 40,
        ),
        title: Text(
          source.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${source.balance.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            color: source.balance >= 0
                ? Colors.green.shade400
                : Colors.red.shade400,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
