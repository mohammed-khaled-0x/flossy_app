// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// App-specific
import 'presentation/managers/cubit/dashboard_cubit.dart';
import 'presentation/managers/cubit/money_sources_cubit.dart';
import 'presentation/managers/cubit/transactions_cubit.dart';
import 'presentation/ui/pages/main_page.dart';
import 'service_locator.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting for our locale
  await initializeDateFormatting('ar_EG', null);
  // Initialize all dependencies (Isar, Cubits, etc.)
  await initializeDependencies();
  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider is the perfect place to provide all our global-state Cubits.
    return MultiBlocProvider(
      providers: [
        // These two Cubits fetch data from the database.
        BlocProvider(create: (_) => sl<MoneySourcesCubit>()),
        BlocProvider(create: (_) => sl<TransactionsCubit>()),

        // This Cubit depends on the ones above. It will be created here and will
        // automatically start listening to them.
        BlocProvider(
          // <<<--- تمت إضافة هذا الجزء
          create: (context) => sl<DashboardCubit>()..loadInitialData(),
        ),
      ],
      child: MaterialApp(
        title: 'فلوسي',
        debugShowCheckedModeBanner: false,
        // --- Localization Settings ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'EG')],
        locale: const Locale('ar', 'EG'),
        // --- Theme Settings ---
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark, // لتفعيل الثيم الغامق
          ),
          fontFamily: 'Tajawal',
          scaffoldBackgroundColor: const Color(0xFF121212), // لون خلفية داكن
          cardColor: const Color(0xFF1E1E1E), // لون الكروت
        ),
        home: const MainPage(),
      ),
    );
  }
}
