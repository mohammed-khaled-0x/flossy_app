import 'package:flutter/material.dart';
import 'package:flossy/service_locator.dart'; // 1. استيراد ملف حقن التبعية

Future<void> main() async {
  // 2. تحويل الدالة إلى async
  // 3. ضمان تهيئة Flutter أولاً قبل أي عمليات أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // 4. استدعاء دالة تهيئة التبعيات وقاعدة البيانات
  await initializeDependencies();

  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.teal),
      home: const Scaffold(body: Center(child: Text('تمت التهيئة بنجاح!'))),
    );
  }
}
