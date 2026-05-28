import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/river_states/currency_provider.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:provider/provider.dart';

import 'package:finance/ui/filter_screen.dart';
import 'package:finance/ui/history_screen.dart';
import 'package:finance/ui/home_screen.dart';
import 'package:finance/ui/statistics_screen.dart';
import 'package:finance/ui/settings_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late List<Widget> _visualPages;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _visualPages = [
      HomeScreen(),
      FilterScreen(),
      StatisticsScreen(),
      HistoryScreen(),
      SettingsScreen(),
    ];
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App resumed');
      Provider.of<LocalSumProvider>(context, listen: false).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _visualPages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(gradient: myGradient),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 38, 175, 79),
          unselectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(size: 29, color: Colors.green),
          unselectedIconTheme: const IconThemeData(
            size: 24,
            color: Colors.white,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Filter',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

