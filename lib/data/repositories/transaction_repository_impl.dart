import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    await localDataSource.addTransaction(transactionModel);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionModels = await localDataSource.getAllTransactions();
    return transactionModels.map((model) => model.toEntity()).toList();
  }
}
