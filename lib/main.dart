import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/treatment_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const SleepCbtApp(),
    ),
  );

  // 启动后异步初始化，不阻塞首帧渲染
  appState.init();
}

class SleepCbtApp extends StatelessWidget {
  const SleepCbtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '安眠 SleepCBT',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        HomeScreen(currentIndex: _currentIndex, onTap: _onTap),
        DiaryScreen(currentIndex: _currentIndex, onTap: _onTap),
        TreatmentScreen(currentIndex: _currentIndex, onTap: _onTap),
        SosScreen(currentIndex: _currentIndex, onTap: _onTap),
        ProgressScreen(currentIndex: _currentIndex, onTap: _onTap),
      ],
    );
  }
}
