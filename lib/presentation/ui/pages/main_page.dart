import 'package:flutter/material.dart';
import 'home_page.dart';
import 'transactions_history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // قائمة الصفحات التي سيتم عرضها
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    TransactionsHistoryPage(),
    // سنضيف هنا صفحة التقارير لاحقًا
    // Text('التقارير'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نعرض الصفحة المختارة من القائمة
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'المصادر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'السجل',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.bar_chart_outlined),
          //   activeIcon: Icon(Icons.bar_chart),
          //   label: 'التقارير',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal.shade800,
        onTap: _onItemTapped,
      ),
    );
  }
}
