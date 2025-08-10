import '../../domain/entities/money_source.dart';
import '../../domain/repositories/money_source_repository.dart';
import '../datasources/local/money_source_local_datasource.dart';
import '../models/money_source_model.dart';

class MoneySourceRepositoryImpl implements MoneySourceRepository {
  final MoneySourceLocalDataSource localDataSource;

  MoneySourceRepositoryImpl({required this.localDataSource});

  @override
  Future<MoneySource> addMoneySource(MoneySource source) async {
    // 1. نحول الكيان (Entity) النظيف إلى نموذج (Model) جاهز للتخزين
    final sourceModel = MoneySourceModel.fromEntity(source);
    // 2. نطلب من مصدر البيانات المحلي إضافة النموذج
    final savedModel = await localDataSource.addMoneySource(sourceModel);
    // 3. Convert the saved model back to an entity and return it.
    return savedModel.toEntity();
  }

  @override
  Future<void> deleteMoneySource(int id) async {
    await localDataSource.deleteMoneySource(id);
  }

  @override
  Future<List<MoneySource>> getAllMoneySources() async {
    // 1. نطلب كل النماذج (Models) من مصدر البيانات المحلي
    final sourceModels = await localDataSource.getAllMoneySources();
    // 2. نحول قائمة النماذج إلى قائمة كيانات (Entities) نظيفة
    // لكي نعيدها لطبقة الـ Domain
    final sources = sourceModels.map((model) => model.toEntity()).toList();
    return sources;
  }

  @override
  Future<void> updateMoneySource(MoneySource source) async {
    final sourceModel = MoneySourceModel.fromEntity(source);
    await localDataSource.updateMoneySource(sourceModel);
  }

  @override
  Future<MoneySource?> getSourceById(int id) async {
    final model = await localDataSource.getSourceById(id);
    if (model != null) {
      return model.toEntity();
    }
    return null;
  }
}
