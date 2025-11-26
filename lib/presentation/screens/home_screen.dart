import 'package:flutter/material.dart';

import 'home/dashboard_screen.dart';
import 'rooms/my_room_screen.dart';

/// MA�n hA�nh trang chA-nh v��>i thanh �`i��?u h����>ng d����>i cA1ng.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    DashboardScreen(),
    ChatbotPlaceholderScreen(),
    MyRoomScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room_outlined), label: 'Phòng của tôi'),
        ],
      ),
    );
  }
}

class ChatbotPlaceholderScreen extends StatelessWidget {
  const ChatbotPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chatbot đang được phát triển. Vui lòng quay lại sau!',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
