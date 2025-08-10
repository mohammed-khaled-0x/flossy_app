// lib/presentation/ui/pages/home_page.dart

// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Domain Layer
import '../../../domain/entities/transaction.dart';

// Presentation Layer
import '../../managers/cubit/dashboard_cubit.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/cubit/transactions_cubit.dart';
import '../../managers/state/dashboard_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return _buildBodyForState(context, state);
        },
      ),
    );
  }

  Widget _buildBodyForState(BuildContext context, DashboardState state) {
    if (state is DashboardLoading || state is DashboardInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DashboardError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('حدث خطأ: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MoneySourcesCubit>().fetchAllMoneySources();
                context.read<TransactionsCubit>().fetchAllTransactions();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<MoneySourcesCubit>().fetchAllMoneySources();
          context.read<TransactionsCubit>().fetchAllTransactions();
        },
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('الخلاصة'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _TotalBalanceCard(totalBalance: state.totalBalance),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'آخر الحركات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // --- THE DEFINITIVE FIX ---
            // We ALWAYS return a SliverList to maintain a consistent widget structure.
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // If the list is empty, build the empty state message.
                    if (state.recentTransactions.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Text(
                            'لا توجد حركات مسجلة بعد.',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ),
                      );
                    }
                    // Otherwise, build the regular transaction tile.
                    final tx = state.recentTransactions[index];
                    return _TransactionTile(transaction: tx);
                  },
                  // If empty, build 1 item (the message). Otherwise, build the list.
                  childCount: state.recentTransactions.isEmpty
                      ? 1
                      : state.recentTransactions.length,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('حالة غير معروفة'));
  }
}

// _TotalBalanceCard and _TransactionTile widgets remain unchanged.
class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  const _TotalBalanceCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرصيد الكلي المتاح',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(totalBalance),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor =
        isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: amountColor,
          size: 30,
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat.yMMMd('ar_EG').format(transaction.date),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
