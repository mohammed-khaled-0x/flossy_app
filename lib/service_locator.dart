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

  // تسجيل مصدر البيانات المحلي
  // نستخدم registerLazySingleton لتوفير الموارد، حيث لن يتم إنشاؤه
  // إلا عند أول مرة يتم طلبه فيها.
  sl.registerLazySingleton<MoneySourceLocalDataSource>(
    () => MoneySourceLocalDataSourceImpl(isar: sl()),
  );

  // ####################
  // # Repositories
  // ####################

  // تسجيل مستودع البيانات
  sl.registerLazySingleton<MoneySourceRepository>(
    () => MoneySourceRepositoryImpl(localDataSource: sl()),
  );

  // --- سنضيف تسجيل الـ Cubits هنا لاحقًا ---
}
