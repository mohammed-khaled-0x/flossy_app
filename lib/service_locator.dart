// Imports from external packages
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Data Layer Imports
import 'data/datasources/local/money_source_local_datasource.dart';
import 'data/datasources/local/transaction_local_datasource.dart';
import 'data/models/category_model.dart';
import 'data/models/money_source_model.dart';
import 'data/models/transaction_model.dart';
import 'data/repositories/money_source_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';

// Domain Layer Imports
import 'domain/repositories/money_source_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/add_money_source.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/get_all_money_sources.dart';
import 'domain/usecases/get_all_transactions.dart';
import 'domain/usecases/update_money_source.dart';

// Presentation Layer Imports
import 'presentation/managers/cubit/dashboard_cubit.dart';
import 'presentation/managers/cubit/money_sources_cubit.dart';
import 'presentation/managers/cubit/transactions_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- Database ---
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    MoneySourceModelSchema,
    TransactionModelSchema,
    CategoryModelSchema,
  ], directory: dir.path);
  sl.registerSingleton<Isar>(isar);

  await _seedDefaultData(isar);

  // --- DataSources ---
  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(isar: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );

  // --- UseCases ---
  sl.registerLazySingleton(() => GetAllMoneySources(sl()));
  sl.registerLazySingleton(() => AddMoneySource(sl()));
  sl.registerLazySingleton(() => UpdateMoneySource(sl()));
  sl.registerLazySingleton(() => GetAllTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));

  // --- Cubits ---
  // These are core application state managers. We register them as LazySingletons
  // to ensure there is only ONE instance of each throughout the app's lifecycle.
  sl.registerLazySingleton(
    // <<<--- CRITICAL CHANGE 1
    () => MoneySourcesCubit(
      getAllMoneySourcesUseCase: sl(),
      addMoneySourceUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    // <<<--- CRITICAL CHANGE 2
    () => TransactionsCubit(
      getAllTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      updateMoneySourceUseCase: sl(),
      getAllMoneySourcesUseCase: sl(),
      moneySourcesCubit:
          sl(), // GetIt will now provide the SINGLE instance of MoneySourcesCubit
    ),
  );

  // This cubit is specific to a view, so it can remain a Factory.
  sl.registerFactory(
    () => DashboardCubit(
      moneySourcesCubit: sl(), // Will get the SINGLE instance
      transactionsCubit: sl(), // Will get the SINGLE instance
    ),
  );
}

/// Seeds the database with default categories on the first run.
Future<void> _seedDefaultData(Isar isar) async {
  // ... (code remains the same)
  final count = await isar.categoryModels.count();
  if (count == 0) {
    final defaultCategories = [
      CategoryModel()
        ..id = 'cat_food'
        ..name = 'أكل و شرب'
        ..iconName = 'fastfood',
      CategoryModel()
        ..id = 'cat_transport'
        ..name = 'مواصلات'
        ..iconName = 'directions_bus',
      CategoryModel()
        ..id = 'cat_bills'
        ..name = 'فواتير وإيجار'
        ..iconName = 'receipt_long',
      CategoryModel()
        ..id = 'cat_shopping'
        ..name = 'تسوق'
        ..iconName = 'shopping_bag',
      CategoryModel()
        ..id = 'cat_entertainment'
        ..name = 'ترفيه'
        ..iconName = 'movie',
      CategoryModel()
        ..id = 'cat_health'
        ..name = 'صحة'
        ..iconName = 'local_hospital',
      CategoryModel()
        ..id = 'cat_gifts'
        ..name = 'هدايا'
        ..iconName = 'card_giftcard',
      CategoryModel()
        ..id = 'cat_general'
        ..name = 'مصاريف عامة'
        ..iconName = 'attach_money',
      CategoryModel()
        ..id = 'cat_income_salary'
        ..name = 'مرتب'
        ..iconName = 'work',
      CategoryModel()
        ..id = 'cat_income_freelance'
        ..name = 'شغل حر'
        ..iconName = 'laptop_chromebook',
    ];

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(defaultCategories);
    });
  }
}
