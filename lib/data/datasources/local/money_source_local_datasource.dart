// lib/data/datasources/local/money_source_local_datasource.dart

import 'package:isar/isar.dart';
import '../../models/money_source_model.dart';

abstract class MoneySourceLocalDataSource {
  Future<List<MoneySourceModel>> getAllMoneySources();
  Future<MoneySourceModel> addMoneySource(MoneySourceModel source);
  Future<void> updateMoneySource(MoneySourceModel source);
  Future<void> deleteMoneySource(int id);
  Future<MoneySourceModel?> getSourceById(int id);
}

class MoneySourceLocalDataSourceImpl implements MoneySourceLocalDataSource {
  final Isar isar;

  MoneySourceLocalDataSourceImpl({required this.isar});

  @override
  Future<MoneySourceModel> addMoneySource(MoneySourceModel source) async {
    // This is the new, foolproof implementation.
    late int newId;
    await isar.writeTxn(() async {
      // 1. Save the object. 'put' returns the final ID.
      newId = await isar.moneySourceModels.put(source);
    });

    // 2. After the transaction is complete, fetch the object we just saved
    //    using its new, definitive ID.
    final savedModel = await isar.moneySourceModels.get(newId);

    // 3. If for some reason it's null, throw an error. Otherwise, return it.
    if (savedModel == null) {
      throw Exception("Failed to save and retrieve the new money source.");
    }
    return savedModel;
  }

  @override
  Future<void> deleteMoneySource(int id) async {
    await isar.writeTxn(() async {
      await isar.moneySourceModels.delete(id);
    });
  }

  @override
  Future<List<MoneySourceModel>> getAllMoneySources() async {
    return await isar.moneySourceModels.where().findAll();
  }

  @override
  Future<void> updateMoneySource(MoneySourceModel source) async {
    // For updates, we don't need to return the object, so the simple 'put' is fine.
    await isar.writeTxn(() async {
      await isar.moneySourceModels.put(source);
    });
  }

  @override
  Future<MoneySourceModel?> getSourceById(int id) async {
    return await isar.moneySourceModels.get(id);
  }
}
