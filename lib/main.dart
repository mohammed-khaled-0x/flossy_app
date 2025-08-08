import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/cubit/transactions_cubit.dart';
import 'package:flossy/presentation/ui/pages/main_page.dart';
import 'package:flossy/service_locator.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_EG', null);
  await initializeDependencies();
  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم MultiBlocProvider لتوفير كل الـ Cubits الرئيسية للتطبيق
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MoneySourcesCubit>()..fetchAllMoneySources(),
        ),
        BlocProvider(
          create: (_) => sl<TransactionsCubit>()..fetchAllTransactions(),
        ),
      ],
      child: MaterialApp(
        title: 'فلوسي',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'EG')],
        locale: const Locale('ar', 'EG'),
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.teal,
          fontFamily: 'Tajawal',
        ),
        // MainPage ستتمكن الآن من الوصول إلى الـ Cubits مباشرة
        home: const MainPage(),
      ),
    );
  }
}
