import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/state/money_sources_state.dart';
import 'package:flossy/presentation/ui/pages/add_transaction_page.dart';
import 'home_page.dart';
import 'transactions_history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    TransactionsHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // نستخدم BlocBuilder هنا للوصول إلى قائمة المصادر وتمريرها
      floatingActionButton: BlocBuilder<MoneySourcesCubit, MoneySourcesState>(
        builder: (context, state) {
          // لا نعرض الزر إلا إذا كانت البيانات محملة وهناك مصادر متاحة
          if (state is MoneySourcesLoaded && state.sources.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // نمرر قائمة المصادر المحملة إلى شاشة الإضافة
                    builder: (_) =>
                        AddTransactionPage(moneySources: state.sources),
                  ),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'إضافة حركة جديدة',
            );
          }
          // في الحالات الأخرى (تحميل، خطأ، لا توجد مصادر)، لا نعرض الزر
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // لعمل قطع في الشريط للزر
        notchMargin: 6.0,
        child: BottomNavigationBar(
          // نجعل الشريط شفافًا ونعتمد على لون BottomAppBar
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal.shade800,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
