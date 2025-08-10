// lib/presentation/ui/pages/transactions_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction.dart';
import '../../managers/cubit/money_sources_cubit.dart';
import '../../managers/cubit/transactions_cubit.dart';
import '../../managers/state/transactions_state.dart';

class TransactionsHistoryPage extends StatelessWidget {
  const TransactionsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحركات'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionsError) {
            return Center(child: Text(state.message));
          }

          if (state is TransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد أي معاملات بعد.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                print(
                    'Building tile for transaction: ${state.transactions[index].description}, Type: ${state.transactions[index].type}');
                final transaction = state.transactions[index];

                // --- THE FIX ---
                // 1. Get the source name from the MoneySourcesCubit using the ID
                final source = context
                    .read<MoneySourcesCubit>()
                    .getSourceById(transaction.sourceId);
                // Provide a fallback name in case the source was deleted
                final sourceName = source?.name ?? 'مصدر محذوف';

                final isExpense = transaction.type == TransactionType.expense;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      // 2. Display both the date and the source name
                      '${DateFormat.yMMMd('ar_EG').add_jm().format(transaction.date)} • $sourceName',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'} ${transaction.amount.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        color: isExpense
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink(); // Fallback for initial state
        },
      ),
    );
  }
}
