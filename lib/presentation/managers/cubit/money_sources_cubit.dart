// External Packages
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Domain Layer
import '../../../domain/entities/money_source.dart';
import '../../../domain/usecases/add_money_source.dart';
import '../../../domain/usecases/get_all_money_sources.dart';

// Presentation Layer
import '../state/money_sources_state.dart';

class MoneySourcesCubit extends Cubit<MoneySourcesState> {
  final GetAllMoneySources getAllMoneySourcesUseCase;
  final AddMoneySource addMoneySourceUseCase;

  MoneySourcesCubit({
    required this.getAllMoneySourcesUseCase,
    required this.addMoneySourceUseCase,
  }) : super(MoneySourcesInitial());

  MoneySource? getSourceById(String id) {
    final currentState = state;
    if (currentState is MoneySourcesLoaded) {
      try {
        return currentState.sources.firstWhere((source) => source.id == id);
      } catch (e) {
        // This will happen if no source is found with the given id.
        return null;
      }
    }
    return null;
  }

  Future<void> fetchAllMoneySources() async {
    // ... (This function is working correctly, no changes needed)
    emit(MoneySourcesLoading());
    try {
      final sources = await getAllMoneySourcesUseCase();
      emit(MoneySourcesLoaded(sources));
    } catch (e) {
      emit(MoneySourcesError('فشل تحميل مصادر الأموال: ${e.toString()}'));
    }
  }

  Future<void> addNewSource({
    required String name,
    required double balance,
    required String iconName,
    required SourceType type,
  }) async {
    // ... (This function is working correctly, no changes needed)
    final currentState = state;
    if (currentState is! MoneySourcesLoaded) return;

    try {
      final newSource = MoneySource(
        id: const Uuid().v4(),
        name: name,
        balance: balance,
        iconName: iconName,
        type: type,
      );

      await addMoneySourceUseCase(newSource);

      final updatedList = List<MoneySource>.from(currentState.sources)
        ..add(newSource);
      emit(MoneySourcesLoaded(updatedList));
    } catch (e) {
      emit(MoneySourcesError('فشل إضافة المصدر: ${e.toString()}'));
    }
  }

  /// This is the instrumented version of the function for deep debugging.
  void updateSourceInState(MoneySource updatedSource) {
    // --- DEBUGGING PRINTS ---
    debugPrint('--- STARTING updateSourceInState ---');
    debugPrint('1. Received updatedSource: $updatedSource');

    final currentState = state;
    debugPrint('2. Current state is: $currentState');

    if (currentState is MoneySourcesLoaded) {
      debugPrint('3. State is MoneySourcesLoaded. Proceeding...');

      final newList = currentState.sources.map((source) {
        if (source.id == updatedSource.id) {
          return updatedSource;
        } else {
          return source;
        }
      }).toList();

      debugPrint('4. New list created. Does it contain the update?');
      // Let's find the updated item in the new list to be sure.
      final itemInNewList = newList.firstWhere((s) => s.id == updatedSource.id);
      debugPrint('   - Item in new list: $itemInNewList');

      final newState = MoneySourcesLoaded(newList);

      // This is the most critical test.
      // If Equatable is working, these two values should be DIFFERENT.
      debugPrint('5. COMPARING STATES:');
      debugPrint('   - Current State HashCode: ${currentState.hashCode}');
      debugPrint('   - New State HashCode:     ${newState.hashCode}');
      debugPrint('   - Are they equal? --> ${currentState == newState}');

      debugPrint('6. ABOUT TO EMIT the new state...');
      emit(newState);
      debugPrint('7. EMITTED new state successfully.');
    } else {
      debugPrint('3. State is NOT MoneySourcesLoaded. Aborting.');
    }
    debugPrint('--- FINISHED updateSourceInState ---');
  }
}
