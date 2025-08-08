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
      // We removed the AppBar from here. It will be a SliverAppBar inside the body.
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return _buildBodyForState(context, state);
        },
      ),
    );
  }

  // Helper method to build the body based on the current state.
  Widget _buildBodyForState(BuildContext context, DashboardState state) {
    if (state is DashboardLoading || state is DashboardInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DashboardError) {
      return Center(
        // ... (Error handling UI remains the same)
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
      // If data is loaded, we use a CustomScrollView with Slivers.
      return RefreshIndicator(
        onRefresh: () async {
          context.read<MoneySourcesCubit>().fetchAllMoneySources();
          context.read<TransactionsCubit>().fetchAllTransactions();
        },
        child: CustomScrollView(
          slivers: [
            // SliverAppBar acts like a normal AppBar but can scroll.
            const SliverAppBar(
              title: Text('الخلاصة'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              // `pinned: true` would make the app bar stick to the top.
              // `floating: true` makes it appear as soon as you scroll up.
              floating: true,
            ),

            // SliverToBoxAdapter allows us to use regular widgets inside a CustomScrollView.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _TotalBalanceCard(totalBalance: state.totalBalance),
              ),
            ),

            // A sliver for adding vertical space.
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // This is the header for the transactions list.
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

            // Now, we build the list of transactions using SliverList.
            _buildRecentTransactionsSliver(context, state.recentTransactions),
          ],
        ),
      );
    }

    // Fallback for any other unhandled state
    return const Center(child: Text('حالة غير معروفة'));
  }

  // New helper method to build the transaction list as a Sliver.
  Widget _buildRecentTransactionsSliver(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'لا توجد حركات مسجلة بعد.',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // SliverList is more efficient than a Column for building lists inside a CustomScrollView.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final tx = transactions[index];
          return _TransactionTile(transaction: tx);
        }, childCount: transactions.length),
      ),
    );
  }
}

// _TotalBalanceCard and _TransactionTile widgets remain exactly the same.
// ... (The code for _TotalBalanceCard and _TransactionTile goes here without any changes)
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
    final amountColor = isIncome
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade400;
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
    );

    // TODO: Fetch category and source details to display names and icons.

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
