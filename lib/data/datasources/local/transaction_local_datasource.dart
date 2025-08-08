import 'package:isar/isar.dart';
import '../../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> addTransaction(TransactionModel transaction);
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
}
