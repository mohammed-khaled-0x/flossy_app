import 'package:flutter/material.dart';

void main() {
  // هنا سنضيف أي إعدادات ضرورية قبل تشغيل التطبيق في المستقبل
  // (مثل تهيئة قواعد البيانات، خدمات تحديد المواقع، إلخ)
  runApp(const FlossyApp());
}

class FlossyApp extends StatelessWidget {
  const FlossyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // لإزالة علامة "Debug" من أعلى يمين الشاشة
      debugShowCheckedModeBanner: false,

      // هنا سنحدد لاحقًا الثيم (الألوان والخطوط) الخاص بالتطبيق بالكامل
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.teal),

      // نقطة البداية لواجهات المستخدم في تطبيقنا
      // سنقوم بإنشاء هذا الملف في الخطوات القادمة
      home: const Scaffold(body: Center(child: Text('قيد الإنشاء...'))),
    );
  }
}
