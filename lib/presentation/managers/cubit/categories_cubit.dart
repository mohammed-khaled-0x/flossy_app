// lib/presentation/managers/cubit/categories_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/domain/usecases/get_all_categories.dart';
import 'package:flossy/presentation/managers/state/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetAllCategories _getAllCategories;

  CategoriesCubit({required GetAllCategories getAllCategories})
      : _getAllCategories = getAllCategories,
        super(CategoriesInitial());

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await _getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
