// lib/main.dart

// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// App-specific
import 'app_bloc_observer.dart';
import 'domain/usecases/add_money_source.dart';
import 'domain/usecases/add_transaction_and_update_source.dart'; // <<<--- السطر المضاف
import 'domain/usecases/get_all_money_sources.dart';
import 'domain/usecases/get_all_transactions.dart';
import 'presentation/managers/cubit/dashboard_cubit.dart';
import 'presentation/managers/cubit/money_sources_cubit.dart';
import 'presentation/managers/cubit/transactions_cubit.dart';
import 'presentation/ui/pages/main_page.dart';
import 'service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_EG', null);
  await initializeDependencies();

  Bloc.observer = AppBlocObserver();

  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MoneySourcesCubit(
            getAllMoneySourcesUseCase: sl<GetAllMoneySources>(),
            addMoneySourceUseCase: sl<AddMoneySource>(),
          )..fetchAllMoneySources(),
        ),
        BlocProvider(
          create: (context) => TransactionsCubit(
            getAllTransactionsUseCase: sl<GetAllTransactions>(),
            addTransactionAndUpdateSourceUseCase:
                sl<AddTransactionAndUpdateSource>(),
            getAllMoneySourcesUseCase: sl<GetAllMoneySources>(),
            moneySourcesCubit: BlocProvider.of<MoneySourcesCubit>(context),
          )..fetchAllTransactions(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (_) => DashboardCubit(
              moneySourcesCubit: BlocProvider.of<MoneySourcesCubit>(context),
              transactionsCubit: BlocProvider.of<TransactionsCubit>(context),
            )..initialize(),
            child: MaterialApp(
              title: 'فلوسي',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [const Locale('ar', 'EG')],
              locale: const Locale('ar', 'EG'),
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.teal,
                  brightness: Brightness.dark,
                ),
                fontFamily: 'Tajawal',
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
              ),
              home: const MainPage(),
            ),
          );
        },
      ),
    );
  }
}
