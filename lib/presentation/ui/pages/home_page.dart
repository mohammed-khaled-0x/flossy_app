// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Domain Layer
import '../../../domain/entities/transaction.dart';

// Presentation Layer
import '../../managers/cubit/dashboard_cubit.dart';
import '../../managers/state/dashboard_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a BlocBuilder to listen to DashboardCubit's state changes.
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('الخلاصة'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _buildBodyForState(context, state),
        );
      },
    );
  }

  // Helper method to build the body based on the current state.
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
              onPressed: () => context.read<DashboardCubit>().loadInitialData(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded) {
      // If data is loaded, we show the main content.
      return RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardCubit>().loadInitialData();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _TotalBalanceCard(totalBalance: state.totalBalance),
            const SizedBox(height: 24),
            _RecentTransactionsSection(transactions: state.recentTransactions),
          ],
        ),
      );
    }

    // Fallback for any other unhandled state
    return const Center(child: Text('حالة غير معروفة'));
  }
}

// A dedicated widget for the total balance card.
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

// A dedicated widget for the recent transactions section.
class _RecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;
  const _RecentTransactionsSection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('آخر الحركات', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'لا توجد حركات مسجلة بعد.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          )
        else
          // We use a Column instead of a ListView to avoid nested scrolling issues.
          Column(
            children: transactions
                .map((tx) => _TransactionTile(transaction: tx))
                .toList(),
          ),
      ],
    );
  }
}

// A dedicated widget for a single transaction tile.
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

    // Here we need to get category and source names.
    // For now, we'll just display IDs. This will be improved later.
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
