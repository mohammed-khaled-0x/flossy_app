import 'package:flutter/material.dart';
import 'package:flossy/presentation/ui/pages/home_page.dart'; // 1. استيراد الصفحة الجديدة
import 'package:flossy/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فلوسي', // اسم التطبيق
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        fontFamily: 'Tajawal', // سنقوم بإضافة هذا الخط لاحقًا
      ),
      // 2. تحديد الصفحة الرئيسية لتكون HomePage
      home: const HomePage(),
    );
  }
}
