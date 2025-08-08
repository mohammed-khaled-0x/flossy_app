import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/money_source.dart';
import '../../managers/cubit/money_sources_cubit.dart';

class AddEditMoneySourcePage extends StatefulWidget {
  const AddEditMoneySourcePage({super.key});

  @override
  State<AddEditMoneySourcePage> createState() => _AddEditMoneySourcePageState();
}

class _AddEditMoneySourcePageState extends State<AddEditMoneySourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  SourceType _selectedType = SourceType.cash;

  // خريطة لربط نوع المصدر بالأيقونة والنص العربي
  final Map<SourceType, Map<String, dynamic>> _sourceTypeDetails = {
    SourceType.cash: {'icon': Icons.money, 'name': 'كاش', 'iconName': 'cash'},
    SourceType.bankAccount: {
      'icon': Icons.account_balance,
      'name': 'حساب بنكي',
      'iconName': 'bank',
    },
    SourceType.electronicWallet: {
      'icon': Icons.account_balance_wallet,
      'name': 'محفظة إلكترونية',
      'iconName': 'wallet',
    },
  };

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // التحقق من أن الفورم صالح
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final balance = double.tryParse(_balanceController.text) ?? 0.0;
      final sourceTypeDetails = _sourceTypeDetails[_selectedType]!;

      // استدعاء دالة الإضافة في الـ Cubit
      context.read<MoneySourcesCubit>().addNewSource(
        name: name,
        balance: balance,
        iconName: sourceTypeDetails['iconName'], // نمرر اسم الأيقونة
        type: _selectedType,
      );

      // إغلاق الشاشة الحالية والعودة للشاشة الرئيسية
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مصدر جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // حقل اسم المصدر
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المصدر',
                  hintText: 'مثال: جيبي، حساب بنك CIB',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اسم المصدر مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // حقل الرصيد
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'الرصيد المبدئي',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرصيد المبدئي مطلوب';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // اختيار نوع المصدر
              Text(
                'نوع المصدر',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SourceType>(
                value: _selectedType,
                items: SourceType.values.map((type) {
                  return DropdownMenuItem<SourceType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _sourceTypeDetails[type]!['icon'],
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(_sourceTypeDetails[type]!['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              // زر الحفظ
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                ),
                child: const Text('حفظ المصدر'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
