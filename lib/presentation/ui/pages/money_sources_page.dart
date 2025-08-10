// lib/presentation/ui/pages/money_sources_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/money_source.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/state/money_sources_state.dart';
import 'add_edit_money_source_page.dart';
import 'add_internal_transfer_page.dart'; // Import the new page

class MoneySourcesPage extends StatelessWidget {
  const MoneySourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the entire Scaffold in a BlocBuilder to control the AppBar actions
    return BlocBuilder<MoneySourcesCubit, MoneySourcesState>(
      builder: (context, state) {
        // Determine if the transfer button should be visible based on the current state
        final canTransfer =
            state is MoneySourcesLoaded && state.sources.length >= 2;

        return Scaffold(
          appBar: AppBar(
            title: const Text('مصادر الأموال'),
            actions: [
              // Conditionally display the transfer button
              if (canTransfer)
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded),
                  tooltip: 'تحويل داخلي',
                  onPressed: () {
                    // We can safely cast the state here because `canTransfer` is true
                    final sources = (state as MoneySourcesLoaded).sources;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddInternalTransferPage(moneySources: sources),
                      ),
                    );
                  },
                ),
              // The "Add" button is always visible
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
          // The body of the scaffold doesn't need its own BlocBuilder anymore
          // as it's already inside one.
          body: _buildBodyForState(context, state),
        );
      },
    );
  }

  // A helper method to build the body content based on the state
  Widget _buildBodyForState(BuildContext context, MoneySourcesState state) {
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
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.sources.isEmpty ? 1 : state.sources.length,
        itemBuilder: (context, index) {
          if (state.sources.isEmpty) {
            return _buildEmptyState(context);
          }
          final source = state.sources[index];
          return _MoneySourceCard(source: source);
        },
      );
    }

    // Fallback for the initial state
    return const Center(child: Text('جاري تهيئة الصفحة...'));
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.6,
      alignment: Alignment.center,
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
}

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
      margin: const EdgeInsets.symmetric(vertical: 4),
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
