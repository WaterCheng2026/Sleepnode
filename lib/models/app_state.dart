import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sleep_diary.dart';

class AppState extends ChangeNotifier {
  List<SleepDiaryEntry> _diaries = [];
  static const _prefsKey = 'sleep_diaries';

  // 缓存频繁计算的结果，addDiary 时失效
  int? _cachedStreak;
  List<double>? _cachedWeekSE;
  double? _cachedAverageSE;

  List<SleepDiaryEntry> get diaries => List.unmodifiable(_diaries);

  int get currentWeek => 3;

  SleepDiaryEntry? get latestDiary =>
      _diaries.isEmpty ? null : _diaries.last;

  bool get hasFilledDiaryToday {
    final today = DateTime.now();
    return _diaries.any((e) =>
        e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day);
  }

  int get streakDays => _cachedStreak ??= _computeStreak();

  int _computeStreak() {
    if (_diaries.isEmpty) return 0;
    final today = DateTime.now();
    DateTime check = DateTime(today.year, today.month, today.day);

    final dateSet = <String>{
      for (final e in _diaries)
        '${e.date.year}-${e.date.month}-${e.date.day}'
    };

    if (!dateSet.contains('${check.year}-${check.month}-${check.day}')) {
      check = check.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (dateSet.contains('${check.year}-${check.month}-${check.day}')) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }

  double get currentSE => latestDiary?.se ?? 0;

  double get averageSE => _cachedAverageSE ??= _computeAverageSE();

  double _computeAverageSE() {
    final recent = _last7Entries();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.se).reduce((a, b) => a + b) / recent.length;
  }

  List<double> get weekSEValues => _cachedWeekSE ??= _computeWeekSE();

  List<double> _computeWeekSE() {
    final today = DateTime.now();
    final dateMap = <String, double>{
      for (final e in _diaries)
        '${e.date.year}-${e.date.month}-${e.date.day}': e.se
    };
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return dateMap['${day.year}-${day.month}-${day.day}'] ?? 0;
    });
  }

  TimeOfDay get windowBedTime => const TimeOfDay(hour: 1, minute: 30);
  TimeOfDay get windowWakeTime => const TimeOfDay(hour: 7, minute: 0);

  List<Map<String, dynamic>> sctItems = [
    {'title': '只在有睡意时才上床', 'checked': false},
    {'title': '床只用于睡觉（不看手机、不工作）', 'checked': false},
    {'title': '20分钟内睡不着则离开床', 'checked': false},
    {'title': '每天固定时间起床', 'checked': false},
    {'title': '白天不补觉', 'checked': false},
    {'title': '睡前避免兴奋性活动', 'checked': false},
    {'title': '卧室保持黑暗安静', 'checked': false},
  ];

  // 14条睡眠卫生习惯题库
  static const List<String> hygienePool = [
    '固定起床时间',
    '避免咖啡因（下午2点后）',
    '午睡不超过20分钟',
    '睡前1小时调暗灯光',
    '卧室温度18-20°C',
    '睡前轻度拉伸',
    '不在床上看手机',
    '避免睡前饮酒',
    '规律运动（非睡前3小时）',
    '睡前温水泡脚',
    '保持卧室安静黑暗',
    '睡前书写担忧清单',
    '避免睡前剧烈讨论',
    '睡前冥想或腹式呼吸',
  ];

  // 今日已选的卫生习惯索引（最多3条）
  final Set<int> selectedHygieneIndices = {};

  void toggleHygieneHabit(int index) {
    if (selectedHygieneIndices.contains(index)) {
      selectedHygieneIndices.remove(index);
    } else if (selectedHygieneIndices.length < 3) {
      selectedHygieneIndices.add(index);
    }
    notifyListeners();
  }

  // SOS凌晨思维记录
  final List<String> sosThoughts = [];

  void addSosThought(String text) {
    sosThoughts.add(text);
    notifyListeners();
  }

  void toggleSctItem(int index) {
    sctItems[index] = Map.from(sctItems[index])
      ..['checked'] = !(sctItems[index]['checked'] as bool);
    notifyListeners();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _diaries = list
          .map((e) => SleepDiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (_diaries.isEmpty) {
      _seedSampleData();
    }
    _invalidateCache();
    notifyListeners();
  }

  Future<void> addDiary(SleepDiaryEntry entry) async {
    _diaries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    _diaries.add(entry);
    _diaries.sort((a, b) => a.date.compareTo(b.date));
    _invalidateCache();
    await _persist();
    notifyListeners();
  }

  void _invalidateCache() {
    _cachedStreak = null;
    _cachedWeekSE = null;
    _cachedAverageSE = null;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_diaries.map((e) => e.toJson()).toList()));
  }

  List<SleepDiaryEntry> _last7Entries() {
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    return _diaries.where((e) => !e.date.isBefore(cutoff)).toList();
  }

  void _seedSampleData() {
    // 16 days of mock data, SE improving from ~63% to ~82%
    // Each entry: bedTime ~01:30, wakeTime ~07:00 (TIB ~5.5h window)
    // But early days have higher SL and WASO -> lower SE
    final today = DateTime.now();

    final seedParams = <List<int>>[
      // [sleepLatency, wakeCount, wakeDuration, mood] - day 1 is oldest
      [55, 3, 60, 2], // day -15: SE ~63%
      [50, 3, 55, 2],
      [48, 3, 50, 2],
      [45, 2, 50, 3], // day -12
      [42, 2, 45, 3],
      [40, 2, 40, 3],
      [38, 2, 38, 3], // day -9: SE ~72%
      [35, 2, 35, 3],
      [33, 2, 30, 3],
      [30, 1, 30, 4], // day -6: SE ~76%
      [28, 1, 25, 4],
      [25, 1, 20, 4],
      [22, 1, 18, 4], // day -3: SE ~80%
      [20, 1, 15, 4],
      [18, 1, 12, 5],
      [15, 1, 10, 5], // day 0 (yesterday): SE ~82%
    ];

    for (int i = 0; i < 16; i++) {
      final daysAgo = 15 - i; // 15 days ago to yesterday
      final date =
          today.subtract(Duration(days: daysAgo + 1)); // +1 so today untouched
      final p = seedParams[i];
      _diaries.add(SleepDiaryEntry(
        id: 'seed_$i',
        date: DateTime(date.year, date.month, date.day),
        bedTime: const TimeOfDay(hour: 1, minute: 30),
        wakeTime: const TimeOfDay(hour: 7, minute: 0),
        sleepLatency: p[0],
        wakeCount: p[1],
        wakeDuration: p[2],
        mood: p[3],
      ));
    }
    _diaries.sort((a, b) => a.date.compareTo(b.date));
  }
}
