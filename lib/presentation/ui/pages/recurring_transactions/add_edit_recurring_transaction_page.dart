// lib/presentation/ui/pages/recurring_transactions/add_edit_recurring_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/domain/entities/category.dart';
import 'package:flossy/data/models/recurring_transaction_model.dart'
    show TransactionType, RecurrencePeriod; // Use enums from data layer for UI
import 'package:flossy/domain/entities/recurring_transaction.dart' as domain;
import 'package:flossy/presentation/managers/cubit/categories_cubit.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/cubit/recurring_transactions/recurring_transactions_cubit.dart';
import 'package:flossy/presentation/managers/state/categories_state.dart';
import 'package:flossy/presentation/managers/state/money_sources_state.dart';
import 'package:flossy/service_locator.dart';
import 'package:intl/intl.dart';

class AddEditRecurringTransactionPage extends StatelessWidget {
  final domain.RecurringTransaction? transaction;

  const AddEditRecurringTransactionPage({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the cubit that this page will use to add data
        BlocProvider.value(
          value: BlocProvider.of<RecurringTransactionsCubit>(context),
        ),
        // Provide the cubit to get the list of categories
        BlocProvider(
          create: (context) => sl<CategoriesCubit>()..fetchCategories(),
        ),
      ],
      child: _AddEditRecurringTransactionView(transaction: transaction),
    );
  }
}

class _AddEditRecurringTransactionView extends StatefulWidget {
  final domain.RecurringTransaction? transaction;

  const _AddEditRecurringTransactionView({this.transaction});

  @override
  State<_AddEditRecurringTransactionView> createState() =>
      _AddEditRecurringTransactionViewState();
}

class _AddEditRecurringTransactionViewState
    extends State<_AddEditRecurringTransactionView> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers and variables
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  RecurrencePeriod _selectedPeriod = RecurrencePeriod.monthly;
  DateTime _selectedDate = DateTime.now();
  int? _selectedSourceId;
  int? _selectedCategoryId;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    // TODO: Implement editing logic by initializing fields from widget.transaction
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_selectedSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار مصدر الأموال')));
      return;
    }
    if (_selectedType == TransactionType.expense &&
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار فئة للمصروف')));
      return;
    }

    final newTransaction = domain.RecurringTransaction(
      id: 0, // 0 for new transactions, Isar will autoincrement
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      type: domain.TransactionType.values.byName(_selectedType.name),
      period: domain.RecurrencePeriod.values.byName(_selectedPeriod.name),
      nextDueDate: _selectedDate,
      sourceId: _selectedSourceId!,
      isActive: true,
      category: context.read<CategoriesCubit>().state is CategoriesLoaded
          ? (context.read<CategoriesCubit>().state as CategoriesLoaded)
              .categories
              .firstWhere((c) => c.id == _selectedCategoryId,
                  orElse: () => null as Category)
          : null,
    );

    context
        .read<RecurringTransactionsCubit>()
        .addRecurringTransaction(newTransaction)
        .then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل الالتزام' : 'إضافة التزام جديد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: _saveForm,
            tooltip: 'حفظ',
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selector
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('مصروف متكرر'),
                      icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(
                      value: TransactionType.income,
                      label: Text('دخل متكرر'),
                      icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: اشتراك نت، إيجار الشقة'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: 16),
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                    labelText: 'المبلغ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on_outlined)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'المبلغ مطلوب';
                  if (double.tryParse(value) == null) return 'قيمة غير صالحة';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Category Dropdown (only for expenses)
              if (_selectedType == TransactionType.expense)
                BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoaded) {
                      return DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                            labelText: 'الفئة', border: OutlineInputBorder()),
                        hint: const Text('اختر فئة المصروف'),
                        items: state.categories
                            .map((cat) => DropdownMenuItem(
                                value: cat.id, child: Text(cat.name)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'الفئة مطلوبة للمصروف' : null,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              if (_selectedType == TransactionType.expense)
                const SizedBox(height: 16),

              // Money Source Dropdown
              BlocBuilder<MoneySourcesCubit, MoneySourcesState>(
                builder: (context, state) {
                  if (state is MoneySourcesLoaded) {
                    return DropdownButtonFormField<int>(
                      value: _selectedSourceId,
                      decoration: const InputDecoration(
                          labelText: 'مصدر الأموال (الافتراضي)',
                          border: OutlineInputBorder()),
                      hint: const Text('اختر المصدر'),
                      items: state.sources
                          .map((source) => DropdownMenuItem(
                              value: source.id, child: Text(source.name)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSourceId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'مصدر الأموال مطلوب' : null,
                    );
                  }
                  return const Text('جاري تحميل مصادر الأموال...');
                },
              ),
              const SizedBox(height: 24),

              // Period Selector
              DropdownButtonFormField<RecurrencePeriod>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                    labelText: 'الدورية (بيتكرر إزاي؟)',
                    border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: RecurrencePeriod.weekly, child: Text('أسبوعيًا')),
                  DropdownMenuItem(
                      value: RecurrencePeriod.monthly, child: Text('شهريًا')),
                  DropdownMenuItem(
                      value: RecurrencePeriod.quarterly,
                      child: Text('كل 3 شهور')),
                  DropdownMenuItem(
                      value: RecurrencePeriod.yearly, child: Text('سنويًا')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Date Picker
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: const Text('تاريخ أول استحقاق'),
                subtitle: Text(DateFormat('EEEE, d MMMM yyyy', 'ar_EG')
                    .format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('حفظ الالتزام'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
