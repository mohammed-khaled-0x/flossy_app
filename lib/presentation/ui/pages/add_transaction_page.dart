import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart'; // نحتاجها لجلب الفئات
import 'package:flossy/service_locator.dart'; // نحتاجها لجلب isar
import '../../../data/models/category_model.dart'; // نحتاجها لجلب الفئات
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
  String? _selectedSourceId;
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    // تحديد قيمة أولية لمصدر الأموال إذا كانت القائمة غير فارغة
    if (widget.moneySources.isNotEmpty) {
      _selectedSourceId = widget.moneySources.first.id;
    }
    _loadCategories();
  }

  // دالة لجلب الفئات من قاعدة البيانات مباشرة
  Future<void> _loadCategories() async {
    final isar = sl<Isar>();
    final cats = await isar.categoryModels.where().findAll();
    setState(() {
      _categories = cats;
      // تحديد قيمة أولية للفئة إذا كانت القائمة غير فارغة
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // استدعاء دالة الإضافة في الـ Cubit
      context.read<TransactionsCubit>().addNewTransaction(
        amount: double.parse(_amountController.text),
        type: _selectedTxType,
        description: _descriptionController.text,
        sourceId: _selectedSourceId!,
        categoryId: _selectedTxType == TransactionType.expense
            ? _selectedCategoryId
            : null,
      );
      // إغلاق الشاشة الحالية
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حركة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // أزرار اختيار النوع (صرف / دخل)
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

              // بقية حقول الفورم
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

              // قائمة منسدلة لمصادر الأموال
              DropdownButtonFormField<String>(
                value: _selectedSourceId,
                items: widget.moneySources.map((source) {
                  return DropdownMenuItem(
                    value: source.id,
                    child: Text(source.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSourceId = val),
                decoration: const InputDecoration(labelText: 'من / إلى'),
                validator: (val) => val == null ? 'يجب اختيار مصدر' : null,
              ),
              const SizedBox(height: 16),

              // قائمة منسدلة للفئات (تظهر فقط في حالة الصرف)
              if (_selectedTxType == TransactionType.expense)
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
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
