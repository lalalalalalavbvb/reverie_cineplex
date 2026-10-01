import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'หน้าหลัก'),
        BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_rounded), label: 'ตั๋วของฉัน'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'โปรไฟล์'),
      ],
    );
  }
}
