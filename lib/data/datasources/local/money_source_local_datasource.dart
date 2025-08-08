// lib/data/datasources/local/money_source_local_datasource.dart

import 'package:isar/isar.dart';
import '../../models/money_source_model.dart';

// The contract defining what our data source must be able to do.
abstract class MoneySourceLocalDataSource {
  Future<List<MoneySourceModel>> getAllMoneySources();
  Future<void> addMoneySource(MoneySourceModel source);
  Future<void> updateMoneySource(MoneySourceModel source);
  // --- CHANGE 1: The ID is now an integer ---
  Future<void> deleteMoneySource(int id);
}

// The actual implementation of the contract using Isar.
class MoneySourceLocalDataSourceImpl implements MoneySourceLocalDataSource {
  final Isar isar;

  MoneySourceLocalDataSourceImpl({required this.isar});

  @override
  Future<void> addMoneySource(MoneySourceModel source) async {
    // Isar's 'put' operation handles both creation and updates.
    await isar.writeTxn(() async {
      await isar.moneySourceModels.put(source);
    });
  }

  @override
  // --- CHANGE 2: The ID is an integer ---
  Future<void> deleteMoneySource(int id) async {
    await isar.writeTxn(() async {
      // --- CHANGE 3: Deletion is now much simpler and more efficient ---
      // We directly use the ID to delete the object. No need to search first.
      await isar.moneySourceModels.delete(id);
    });
  }

  @override
  Future<List<MoneySourceModel>> getAllMoneySources() async {
    return await isar.moneySourceModels.where().findAll();
  }

  @override
  Future<void> updateMoneySource(MoneySourceModel source) async {
    // We can reuse the addMoneySource logic because 'put' handles updates.
    await addMoneySource(source);
  }
}
