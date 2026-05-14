import 'package:flutter/material.dart';
import '../theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      backgroundColor: Colors.white,
      elevation: 8,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '主页'),
        const BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: '日记'),
        const BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: '练习'),
        BottomNavigationBarItem(
          icon: Badge(label: const Text(''), isLabelVisible: true, child: const Icon(Icons.dark_mode_outlined)),
          activeIcon: Badge(label: const Text(''), isLabelVisible: true, child: const Icon(Icons.dark_mode)),
          label: '凌晨',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: '进度'),
      ],
    );
  }
}
