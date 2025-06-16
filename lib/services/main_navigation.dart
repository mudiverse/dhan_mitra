
import 'package:dhan_mitra_final/pages/main_pages/home_page.dart';
import 'package:dhan_mitra_final/pages/main_pages/my_transactions.dart';
import 'package:dhan_mitra_final/pages/main_pages/payment_rooms.dart';
import 'package:dhan_mitra_final/pages/main_pages/profile_page.dart';
import 'package:dhan_mitra_final/pages/main_pages/split_money_page.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  //list of pages //TODO: any more pages add here
  final List<Widget> _pages = [
    const HomePage(),
    const MyTransactions(),
    const SplitMoneyPage(),
    const PaymentRoomsPage(),
    const ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white70,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.money_sharp), label: 'Splits'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
        ],
      ),
    );
  }
}
