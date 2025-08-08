import 'package:flutter_bloc/flutter_bloc.dart';

// This class will observe all state changes in the application.
class AppBlocObserver extends BlocObserver {
  // Called whenever a Cubit is created.
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('✅ OBSERVER: ${bloc.runtimeType} created');
  }

  // This is the most important one for us.
  // Called whenever a new state is emitted.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔄 OBSERVER: ${bloc.runtimeType} changed');
    print('   - Current State: ${change.currentState}');
    print('   - Next State:    ${change.nextState}');
  }

  // Called whenever an error occurs.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('❌ OBSERVER: ${bloc.runtimeType} threw an error: $error');
    super.onError(bloc, error, stackTrace);
  }

  // Called whenever a Cubit is closed.
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('🗑️ OBSERVER: ${bloc.runtimeType} closed');
  }
}
