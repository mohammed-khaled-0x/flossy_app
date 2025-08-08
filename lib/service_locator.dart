import 'package:flossy/domain/usecases/add_money_source.dart';
import 'package:flossy/domain/usecases/get_all_money_sources.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
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

  // تهيئة قاعدة بيانات Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [MoneySourceModelSchema], // نخبر Isar بكل الـ Schemas التي لدينا
    directory: dir.path,
  );

  // تسجيل نسخة Isar المفتوحة كـ Singleton
  sl.registerSingleton<Isar>(isar);

  // ####################
  // # Data Sources
  // ####################

  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );

  // ####################
  // # Repositories
  // ####################

  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );

  // ####################
  // # Use Cases
  // ####################

  sl.registerLazySingleton(() => GetAllMoneySources(sl()));
  sl.registerLazySingleton(() => AddMoneySource(sl()));
  // ... سنضيف بقية الـ Use Cases هنا

  // ####################
  // # Cubits (Business Logic Components)
  // ####################

  // نستخدم registerFactory للـ Cubits لأننا قد نحتاج إلى نسخة جديدة
  // منها في كل مرة نفتح فيها شاشة معينة.
  sl.registerFactory(
    () => MoneySourcesCubit(
      getAllMoneySourcesUseCase: sl(),
      addMoneySourceUseCase: sl(), // التحديث هنا
    ),
  );
}
