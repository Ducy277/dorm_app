import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import 'bookings/bookings_screen.dart';
import 'bills/bills_screen.dart';
import 'repairs/repairs_screen.dart';
import 'profile/profile_screen.dart';
import 'home/dashboard_screen.dart';

/// Màn hình trang chính với thanh điều hướng dưới cùng.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardScreen(),
      BookingsScreen(),
      BillsScreen(),
      RepairsScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: AppStrings.rooms),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: AppStrings.bookings),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: AppStrings.bills),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: AppStrings.repairs),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }
}