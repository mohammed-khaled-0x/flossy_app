import 'package:isar/isar.dart';
import '../../models/transaction_model.dart';
import 'package:flossy/data/models/category_model.dart';

typedef IsarWriteCallback = Future<void> Function(Isar isar);

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> performAtomicWrite(IsarWriteCallback callback);
  Future<List<CategoryModel>> getAllCategories();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Isar isar;

  TransactionLocalDataSourceImpl({required this.isar});

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    // نرتب المعاملات حسب التاريخ (الأحدث أولاً)
    return await isar.transactionModels.where().sortByDateDesc().findAll();
  }

  @override
  Future<void> performAtomicWrite(IsarWriteCallback callback) async {
    await isar.writeTxn(() => callback(isar));
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return await isar.categoryModels.where().findAll();
  }
}
