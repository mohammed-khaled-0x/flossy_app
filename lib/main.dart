import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 1. استيراد لدعم اللغة
import 'package:flossy/presentation/ui/pages/main_page.dart'; // 2. استيراد MainPage
import 'package:flossy/service_locator.dart';
import 'package:intl/date_symbol_data_local.dart'; // 3. استيراد لدعم تواريخ intl

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 4. تهيئة بيانات اللغة العربية لحزمة intl
  await initializeDateFormatting('ar_EG', null);

  await initializeDependencies();
  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فلوسي',
      debugShowCheckedModeBanner: false,

      // 5. إضافة دعم اللغات والاتجاه
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'), // اللغة العربية
      ],
      locale: const Locale('ar', 'EG'), // تحديد اللغة الافتراضية

      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        fontFamily: 'Tajawal', // سنقوم بإضافة هذا الخط لاحقًا
      ),

      // 6. تحديد الصفحة الرئيسية لتكون MainPage
      home: const MainPage(),
    );
  }
}
