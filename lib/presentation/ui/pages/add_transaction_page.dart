// lib/presentation/ui/pages/add_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:flossy/service_locator.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/money_source.dart';
import '../../../domain/entities/transaction.dart';
import '../../managers/cubit/transactions_cubit.dart';

class AddTransactionPage extends StatefulWidget {
  final List<MoneySource> moneySources;

  const AddTransactionPage({super.key, required this.moneySources});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _selectedTxType = TransactionType.expense;
  int? _selectedSourceId;
  int? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    // We remove the logic from here. It's safer to handle it in the build method
    // or didChangeDependencies to react to changes in the widget's properties.
    _loadCategories();
  }

  // --- NEW METHOD ---
  // This method is called whenever the dependencies of this State object change.
  // It's a safer place to initialize state that depends on widget properties.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If no source is selected yet AND the list of sources is not empty
    if (_selectedSourceId == null && widget.moneySources.isNotEmpty) {
      // Set the initial value to the first source in the list
      _selectedSourceId = widget.moneySources.first.id;
    }
    // --- SAFETY CHECK ---
    // If a source ID IS selected, but it's no longer in the list of available sources
    // (e.g., it was deleted), we reset it to the first available source to avoid crashing.
    else if (_selectedSourceId != null &&
        !widget.moneySources.any((source) => source.id == _selectedSourceId)) {
      _selectedSourceId = widget.moneySources.isNotEmpty
          ? widget.moneySources.first.id
          : null;
    }
  }

  Future<void> _loadCategories() async {
    final isar = sl<Isar>();
    final cats = await isar.categoryModels.where().findAll();
    // Ensure the widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        _categories = cats;
        if (_categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Add a check to ensure a source is selected before submitting
    if (_selectedSourceId == null) {
      // Optionally, show a snackbar to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة مصدر أموال أولاً.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<TransactionsCubit>().addNewTransaction(
        amount: double.parse(_amountController.text),
        type: _selectedTxType,
        description: _descriptionController.text,
        sourceId: _selectedSourceId!,
        categoryId: _selectedTxType == TransactionType.expense
            ? _selectedCategoryId
            : null,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no money sources, show a message instead of the form.
    if (widget.moneySources.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('إضافة حركة جديدة')),
        body: const Center(
          child: Text('يجب إضافة مصدر أموال واحد على الأقل قبل تسجيل أي حركة.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حركة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ... Rest of the form is the same ...
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('صرف'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('دخل'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedTxType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedTxType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                validator: (val) => val!.isEmpty ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'المبلغ مطلوب';
                  if (double.tryParse(val) == null) return 'رقم غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedSourceId,
                items: widget.moneySources.map((source) {
                  return DropdownMenuItem<int>(
                    value: source.id,
                    child: Text(source.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSourceId = val),
                decoration: const InputDecoration(labelText: 'من / إلى'),
                validator: (val) => val == null ? 'يجب اختيار مصدر' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedTxType == TransactionType.expense)
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  decoration: const InputDecoration(labelText: 'تحت فئة'),
                  validator: (val) => val == null ? 'يجب اختيار فئة' : null,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('حفظ الحركة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
