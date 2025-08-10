// lib/presentation/ui/pages/recurring_transactions/recurring_transactions_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/domain/entities/recurring_transaction.dart';
import 'package:flossy/presentation/managers/cubit/recurring_transactions/recurring_transactions_cubit.dart';
import 'package:flossy/presentation/managers/state/recurring_transactions_state.dart';
import 'package:flossy/service_locator.dart';
import 'package:intl/intl.dart';
import 'add_edit_recurring_transaction_page.dart';

class RecurringTransactionsPage extends StatelessWidget {
  const RecurringTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<RecurringTransactionsCubit>()..fetchRecurringTransactions(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الالتزامات الدورية'),
        ),
        body:
            BlocBuilder<RecurringTransactionsCubit, RecurringTransactionsState>(
          builder: (context, state) {
            if (state is RecurringTransactionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecurringTransactionsError) {
              return Center(child: Text('حدث خطأ: ${state.message}'));
            } else if (state is RecurringTransactionsLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'مفيش التزامات متسجلة.\nضيف فواتيرك واشتراكاتك عشان متتنسيش!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }
              // Build the list of recurring transaction cards
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return RecurringTransactionCard(transaction: transaction);
                },
              );
            }
            return const Center(child: Text('ابدأ بتحميل البيانات'));
          },
        ),
        floatingActionButton: Builder(
          builder: (buttonContext) {
            // This `buttonContext` is guaranteed to be below the BlocProvider
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(buttonContext).push(
                  MaterialPageRoute(
                    // Pass the Cubit instance using the correct context
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<RecurringTransactionsCubit>(
                          buttonContext),
                      child: const AddEditRecurringTransactionPage(),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'إضافة التزام جديد',
            );
          },
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    // This context is from the Builder, so it's below the BlocProvider and can find the Cubit.
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: BlocProvider.of<RecurringTransactionsCubit>(context),
            child: const AddEditRecurringTransactionPage(),
          ),
        ));
      },
      child: const Icon(Icons.add),
      tooltip: 'إضافة التزام جديد',
    );
  }
}

class RecurringTransactionCard extends StatelessWidget {
  final RecurringTransaction transaction;
  const RecurringTransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isDue = transaction.nextDueDate.isBefore(DateTime.now());
    final Color dueColor = Colors.orange.shade700;
    final theme = Theme.of(context);

    // Date formatting
    final DateFormat formatter = DateFormat('d MMMM yyyy', 'ar_EG');
    final String formattedDate = formatter.format(transaction.nextDueDate);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDue ? BorderSide(color: dueColor, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon, Description, and Amount
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: transaction.type == TransactionType.expense
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  child: Icon(
                    transaction.type == TransactionType.expense
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: transaction.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transaction.description,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${transaction.type == TransactionType.expense ? '-' : '+'} ${transaction.amount.toStringAsFixed(2)} جنيه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.type == TransactionType.expense
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Bottom Row: Due date and Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاستحقاق القادم:',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isDue ? dueColor : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                if (isDue)
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<RecurringTransactionsCubit>()
                        .logPayment(transaction),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('سجّل الدفعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dueColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
