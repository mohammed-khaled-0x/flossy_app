// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Presentation Layer
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/state/money_sources_state.dart';
import 'package:flossy/presentation/ui/pages/add_transaction_page.dart';
import 'home_page.dart';
import 'money_sources_page.dart'; // <<<--- 1. استيراد الصفحة الجديدة
import 'transactions_history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // We start with the Dashboard (HomePage) as the first page.
  int _selectedIndex = 0;

  // The list of pages our BottomNavBar will switch between.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Index 0: Dashboard
    MoneySourcesPage(), // Index 1: List of Wallets/Sources
    TransactionsHistoryPage(), // Index 2: Full History
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // The FloatingActionButton is now simpler. It's always visible and always adds a transaction.
      // The logic to enable/disable it is implicitly handled by the user not being able to
      // add a transaction without sources, which is handled on the AddTransactionPage.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We need the state of sources to pass to the next page
          final state = context.read<MoneySourcesCubit>().state;
          if (state is MoneySourcesLoaded && state.sources.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionPage(moneySources: state.sources),
              ),
            );
          } else {
            // Optional: Show a message if there are no sources to transact with.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يجب إضافة مصدر أموال أولاً!'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        shape: const CircleBorder(),
        tooltip: 'إضافة حركة جديدة',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,

          // We now have 3 items in the navigation bar
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'الخلاصة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'المصادر', // <<<--- 2. إضافة التبويب الجديد
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'السجل',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
