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
import 'package:flossy/presentation/managers/cubit/transactions_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'data/datasources/local/money_source_local_datasource.dart';
import 'data/models/money_source_model.dart';
import 'data/repositories/money_source_repository_impl.dart';
import 'domain/repositories/money_source_repository.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ... (كل الأكواد السابقة كما هي)

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    MoneySourceModelSchema,
    TransactionModelSchema,
    CategoryModelSchema,
  ], directory: dir.path);
  sl.registerSingleton<Isar>(isar);

  // استدعاء دالة إضافة البيانات الافتراضية
  await _seedDefaultData(isar);

  // ... (بقية تسجيلات التبعية كما هي)

  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(isar: sl()),
  );

  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetAllMoneySources(sl()));
  sl.registerLazySingleton(() => AddMoneySource(sl()));

  sl.registerLazySingleton(() => GetAllTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));

  sl.registerFactory(
    () => MoneySourcesCubit(
      getAllMoneySourcesUseCase: sl(),
      addMoneySourceUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => TransactionsCubit(
      getAllTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      moneySourceRepository: sl(),
      moneySourcesCubit: sl(), // GetIt سيبحث عن MoneySourcesCubit المسجل ويمرره
    ),
  );
}

/// دالة لإضافة البيانات الافتراضية (مثل الفئات) عند أول تشغيل
Future<void> _seedDefaultData(Isar isar) async {
  // تحقق مما إذا كانت هناك أي فئات موجودة بالفعل
  final count = await isar.categoryModels.count();
  if (count == 0) {
    // إذا كانت قاعدة البيانات فارغة، أضف الفئات الافتراضية
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

    // حفظ الفئات الجديدة في قاعدة البيانات
    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(defaultCategories);
    });
  }
}
