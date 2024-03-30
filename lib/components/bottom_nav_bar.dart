import 'package:cashswift/pages/home.dart';
import 'package:cashswift/pages/loadmoney.dart';
import 'package:cashswift/pages/sendmoney.dart';
import 'package:cashswift/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// nav_bar.dart


class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LoadMoney(),
    const SendMoneyScreen(),
    const TransactionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.tertiary,
        animationDuration: Duration(milliseconds: 400),
        items: [
          Icon(
            Icons.home,
            color: Theme.of(context).colorScheme.onTertiary,
            size: 30,
          ),
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.onTertiary,
            size: 30,
          ),
          Icon(
            Icons.qr_code,
            color: Theme.of(context).colorScheme.onTertiary,
            size: 30,
          ),
          Icon(
            Icons.history,
            color: Theme.of(context).colorScheme.onTertiary,
            size: 30,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}