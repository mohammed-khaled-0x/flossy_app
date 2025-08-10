// lib/presentation/ui/pages/add_internal_transfer_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/money_source.dart';
import '../../managers/cubit/transactions_cubit.dart';

class AddInternalTransferPage extends StatefulWidget {
  final List<MoneySource> moneySources;

  const AddInternalTransferPage({super.key, required this.moneySources});

  @override
  State<AddInternalTransferPage> createState() =>
      _AddInternalTransferPageState();
}

class _AddInternalTransferPageState extends State<AddInternalTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _fromSourceId;
  int? _toSourceId;

  @override
  void initState() {
    super.initState();
    // Set initial values if possible
    if (widget.moneySources.length >= 2) {
      _fromSourceId = widget.moneySources[0].id;
      _toSourceId = widget.moneySources[1].id;
    } else if (widget.moneySources.length == 1) {
      _fromSourceId = widget.moneySources[0].id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<TransactionsCubit>().performTransfer(
            amount: double.parse(_amountController.text),
            fromSourceId: _fromSourceId!,
            toSourceId: _toSourceId!,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحويل داخلي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'المبلغ مطلوب';
                  final amount = double.tryParse(val);
                  if (amount == null) return 'رقم غير صحيح';
                  if (amount <= 0) return 'يجب أن يكون المبلغ أكبر من صفر';
                  // Check if the source has enough balance
                  final fromSource = widget.moneySources
                      .firstWhere((s) => s.id == _fromSourceId);
                  if (amount > fromSource.balance) {
                    return 'الرصيد في هذا المصدر غير كافٍ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // "From" Source Dropdown
              DropdownButtonFormField<int>(
                value: _fromSourceId,
                items: widget.moneySources.map((source) {
                  return DropdownMenuItem<int>(
                    value: source.id,
                    child: Text(source.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _fromSourceId = val),
                decoration: const InputDecoration(labelText: 'من مصدر'),
                validator: (val) {
                  if (val == null) return 'يجب اختيار مصدر';
                  if (val == _toSourceId) {
                    return 'لا يمكن التحويل لنفس المصدر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // "To" Source Dropdown
              DropdownButtonFormField<int>(
                value: _toSourceId,
                items: widget.moneySources.map((source) {
                  return DropdownMenuItem<int>(
                    value: source.id,
                    child: Text(source.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _toSourceId = val),
                decoration: const InputDecoration(labelText: 'إلى مصدر'),
                validator: (val) {
                  if (val == null) return 'يجب اختيار مصدر';
                  if (val == _fromSourceId) {
                    return 'لا يمكن التحويل لنفس المصدر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('تنفيذ التحويل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
