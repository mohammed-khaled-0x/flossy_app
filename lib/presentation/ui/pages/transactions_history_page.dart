import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction.dart';
import '../../managers/cubit/transactions_cubit.dart';
import '../../managers/state/transactions_state.dart';

class TransactionsHistoryPage extends StatelessWidget {
  const TransactionsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // تم حذف الـ BlocProvider من هنا
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
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                final isExpense = transaction.type == TransactionType.expense;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    title: Text(transaction.description),
                    subtitle: Text(
                      DateFormat.yMMMd(
                        'ar_EG',
                      ).add_jm().format(transaction.date),
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'} ${transaction.amount.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        color: isExpense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
