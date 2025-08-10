// lib/presentation/ui/pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flossy/presentation/managers/cubit/money_sources_cubit.dart';
import 'package:flossy/presentation/managers/state/money_sources_state.dart';
import 'package:flossy/presentation/ui/pages/add_transaction_page.dart';
import 'home_page.dart';
import 'money_sources_page.dart';
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
    MoneySourcesPage(),
    TransactionsHistoryPage(),
    SettingsPage(), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- THE DEFINITIVE FIX ---
    // We wrap everything in a Stack to manually place the FAB on top,
    // breaking the problematic layout dependency chain within the Scaffold.
    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

          // CRITICAL: The FAB is NOT part of the Scaffold anymore.
          // This prevents the Scaffold from trying to calculate its geometry
          // in relation to the BottomAppBar, which is the source of the loop.

          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(
                    icon: Icons.dashboard_rounded, label: 'الخلاصة', index: 0),
                _buildNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'المصادر',
                    index: 1),
                const SizedBox(width: 48), // Spacer for the FAB
                _buildNavItem(
                    icon: Icons.history_rounded, label: 'السجل', index: 2),
                _buildNavItem(
                    icon: Icons.settings_rounded, label: 'الإعدادات', index: 3),
              ],
            ),
          ),
        ),

        // This is the FAB, placed manually in the Stack.
        Positioned(
          bottom: 30, // Adjust this value to vertically center the FAB
          left: 0,
          right: 0,
          child: FloatingActionButton(
            onPressed: () {
              final state = context.read<MoneySourcesCubit>().state;
              if (state is MoneySourcesLoaded && state.sources.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AddTransactionPage(moneySources: state.sources),
                  ),
                );
              } else {
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
        ),
      ],
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final color = _selectedIndex == index
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}

// Placeholder for the Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings - Coming Soon'));
  }
}
