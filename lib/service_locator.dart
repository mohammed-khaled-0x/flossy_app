// Imports from external packages
import 'package:flutter/foundation.dart'; // <<<--- [ADD] إضافة مهمة
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Data Layer Imports
import 'data/datasources/local/money_source_local_datasource.dart';
import 'data/datasources/local/recurring_transaction_local_datasource.dart';
import 'data/datasources/local/transaction_local_datasource.dart';
import 'data/models/category_model.dart';
import 'data/models/money_source_model.dart';
import 'data/models/recurring_transaction_model.dart';
import 'data/models/transaction_model.dart';
import 'data/repositories/money_source_repository_impl.dart';
import 'data/repositories/recurring_transaction_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';

// Domain Layer Imports
import 'domain/repositories/money_source_repository.dart';
import 'domain/repositories/recurring_transaction_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/add_transaction_and_update_source.dart';
import 'domain/usecases/perform_internal_transfer.dart';
import 'domain/usecases/add_money_source.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/get_all_money_sources.dart';
import 'domain/usecases/get_all_transactions.dart';
import 'domain/usecases/add_recurring_transaction.dart';
import 'presentation/managers/cubit/recurring_transactions/recurring_transactions_cubit.dart';
import 'domain/usecases/get_all_recurring_transactions.dart';
import 'domain/usecases/update_recurring_transaction.dart';
import 'domain/usecases/update_money_source.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- Database ---
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      MoneySourceModelSchema,
      TransactionModelSchema,
      CategoryModelSchema,
      RecurringTransactionModelSchema, // Add new schema
    ],
    // [MODIFICATION] التعديل الرئيسي هنا
    // We only enable the inspector in debug builds.
    // kDebugMode is a constant from flutter/foundation.dart
    inspector: kDebugMode,
    directory: dir.path,
  );
  sl.registerSingleton<Isar>(isar);

  await _seedDefaultData(isar);

  // --- DataSources ---
  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<RecurringTransactionLocalDataSource>(
    () => RecurringTransactionLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(isar: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(transactionLocalDataSource: sl()),
  );

  // --- UseCases ---
  sl.registerLazySingleton(() => GetAllMoneySources(sl()));
  sl.registerLazySingleton(() => AddMoneySource(sl()));
  sl.registerLazySingleton(() => UpdateMoneySource(sl()));
  sl.registerLazySingleton(() => GetAllTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => AddTransactionAndUpdateSource(sl()));
  sl.registerLazySingleton(() => PerformInternalTransfer(sl()));
  sl.registerLazySingleton(() => AddRecurringTransaction(sl()));
  sl.registerLazySingleton(() => GetAllRecurringTransactions(sl()));
  sl.registerLazySingleton(() => UpdateRecurringTransaction(sl()));
  sl.registerFactory(
    () => RecurringTransactionsCubit(
      getAllRecurringTransactions: sl(),
      addRecurringTransaction: sl(),
      updateRecurringTransaction: sl(),
    ),
  );
  // --- Cubits ---
  // These are core application state managers. We register them as LazySingletons
  // to ensure there is only ONE instance of each throughout the app's lifecycle.
}

/// Seeds the database with default categories on the first run.
Future<void> _seedDefaultData(Isar isar) async {
  final count = await isar.categoryModels.count();
  if (count == 0) {
    final defaultCategories = [
      CategoryModel()
        ..name = 'أكل و شرب'
        ..iconName = 'fastfood',
      CategoryModel()
        ..name = 'مواصلات'
        ..iconName = 'directions_bus',
      CategoryModel()
        ..name = 'فواتير وإيجار'
        ..iconName = 'receipt_long',
      CategoryModel()
        ..name = 'تسوق'
        ..iconName = 'shopping_bag',
      CategoryModel()
        ..name = 'ترفيه'
        ..iconName = 'movie',
      CategoryModel()
        ..name = 'صحة'
        ..iconName = 'local_hospital',
      CategoryModel()
        ..name = 'هدايا'
        ..iconName = 'card_giftcard',
      CategoryModel()
        ..name = 'مصاريف عامة'
        ..iconName = 'attach_money',
      CategoryModel()
        ..name = 'مرتب'
        ..iconName = 'work',
      CategoryModel()
        ..name = 'شغل حر'
        ..iconName = 'laptop_chromebook',
    ];

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(defaultCategories);
    });
  }
}
