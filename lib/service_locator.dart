import 'package:flossy/data/datasources/local/transaction_local_datasource.dart';
import 'package:flossy/data/models/category_model.dart';
import 'package:flossy/data/models/transaction_model.dart';
import 'package:flossy/data/repositories/transaction_repository_impl.dart';
import 'package:flossy/domain/repositories/transaction_repository.dart';
import 'package:flossy/domain/usecases/add_money_source.dart';
import 'package:flossy/domain/usecases/add_transaction.dart';
import 'package:flossy/domain/usecases/get_all_money_sources.dart';
import 'package:flossy/domain/usecases/get_all_transactions.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/cubit/transactions_cubit.dart'; // 1. استيراد الـ Cubit الجديد
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'data/datasources/local/money_source_local_datasource.dart';
import 'data/models/money_source_model.dart';
import 'data/repositories/money_source_repository_impl.dart';
import 'domain/repositories/money_source_repository.dart';

// ننشئ نسخة من GetIt لنستخدمها في كل التطبيق
final sl = GetIt.instance;

/// هذه الدالة هي المسؤولة عن تهيئة وتسجيل كل الخدمات والتبعيات
Future<void> initializeDependencies() async {
  // ####################
  // # External
  // ####################

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    MoneySourceModelSchema,
    TransactionModelSchema,
    CategoryModelSchema,
  ], directory: dir.path);
  sl.registerSingleton<Isar>(isar);

  // ####################
  // # Data Sources
  // ####################

  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(isar: sl()),
  );

  // ####################
  // # Repositories
  // ####################

  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );

  // ####################
  // # Use Cases
  // ####################

  sl.registerLazySingleton(() => GetAllMoneySources(sl()));
  sl.registerLazySingleton(() => AddMoneySource(sl()));

  sl.registerLazySingleton(() => GetAllTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));

  // ####################
  // # Cubits (Business Logic Components)
  // ####################

  sl.registerFactory(
    () => MoneySourcesCubit(
      getAllMoneySourcesUseCase: sl(),
      addMoneySourceUseCase: sl(),
    ),
  );

  // 2. تسجيل الـ Cubit الجديد مع كل تبعياته
  sl.registerFactory(
    () => TransactionsCubit(
      getAllTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      moneySourceRepository:
          sl(), // GetIt سيقوم بتمرير الـ Repository المطلوب تلقائيًا
    ),
  );
}
