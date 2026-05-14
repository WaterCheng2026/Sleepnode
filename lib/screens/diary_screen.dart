import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/sleep_diary.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class DiaryScreen extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DiaryScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 1, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _sleepLatency = 20;
  int _wakeCount = 1;
  int _wakeDuration = 15;
  int _mood = 4;

  double get _tib {
    double bed = _bedTime.hour + _bedTime.minute / 60.0;
    double wake = _wakeTime.hour + _wakeTime.minute / 60.0;
    if (wake <= bed) wake += 24;
    return wake - bed;
  }

  double get _tst {
    final v = _tib - _sleepLatency / 60.0 - _wakeDuration / 60.0;
    return v < 0 ? 0 : v;
  }

  double get _se => _tib > 0 ? (_tst / _tib).clamp(0.0, 1.0) : 0;

  Future<void> _pickTime(bool isBed) async {
    final initial = isBed ? _bedTime : _wakeTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isBed) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _submit() {
    final state = context.read<AppState>();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final entry = SleepDiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime(yesterday.year, yesterday.month, yesterday.day),
      bedTime: _bedTime,
      wakeTime: _wakeTime,
      sleepLatency: _sleepLatency,
      wakeCount: _wakeCount,
      wakeDuration: _wakeDuration,
      mood: _mood,
    );
    state.addDiary(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('睡眠日记已保存 ✓'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final windowBed = state.windowBedTime;
    final windowWake = state.windowWakeTime;
    final tibH = _tib;
    final inWindow = (tibH - 5.5).abs() < 0.5;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: '睡眠日记',
              subtitle: '今日晨起填写 · 记录昨晚数据',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Bed / wake time
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '上床与起床时间'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeTile(
                              label: '上床时间',
                              time: _formatTime(_bedTime),
                              onTap: () => _pickTime(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimeTile(
                              label: '起床时间',
                              time: _formatTime(_wakeTime),
                              onTap: () => _pickTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: inWindow ? AppColors.greenBg : AppColors.amberBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bed, size: 15, color: inWindow ? AppColors.greenText : AppColors.amberText),
                            const SizedBox(width: 6),
                            Text(
                              '卧床时间: ${tibH.toStringAsFixed(1)}小时  (睡眠窗口 ${_formatTime(windowBed)}-${_formatTime(windowWake)})',
                              style: TextStyle(fontSize: 12, color: inWindow ? AppColors.greenText : AppColors.amberText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Sleep latency
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '入睡时间'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.bedtime_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('上床后约 $_sleepLatency 分钟入睡',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      Slider(
                        value: _sleepLatency.toDouble(),
                        min: 0,
                        max: 90,
                        divisions: 18,
                        activeColor: AppColors.primary,
                        label: '$_sleepLatency min',
                        onChanged: (v) => setState(() => _sleepLatency = v.round()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Text('90 min', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Wake count
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '夜间醒来次数'),
                      Row(
                        children: [
                          const Icon(Icons.nights_stay_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('夜间醒来 $_wakeCount 次',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      Slider(
                        value: _wakeCount.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        activeColor: AppColors.primary,
                        label: '$_wakeCount',
                        onChanged: (v) => setState(() => _wakeCount = v.round()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Text('10次', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Wake duration
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '夜醒总时长 (WASO)'),
                      Row(
                        children: [
                          const Icon(Icons.watch_later_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('夜间清醒约 $_wakeDuration 分钟',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      Slider(
                        value: _wakeDuration.toDouble(),
                        min: 0,
                        max: 120,
                        divisions: 24,
                        activeColor: AppColors.primary,
                        label: '$_wakeDuration min',
                        onChanged: (v) => setState(() => _wakeDuration = (v / 5).round() * 5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('0', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Text('120 min', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Mood
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '睡眠质量感受'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (i) {
                          final moods = ['😞', '😕', '😐', '😊', '😄'];
                          final labels = ['很差', '较差', '一般', '较好', '很好'];
                          final v = i + 1;
                          final selected = _mood == v;
                          return GestureDetector(
                            onTap: () => setState(() => _mood = v),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.primaryLight : AppColors.bgSecondary,
                                    shape: BoxShape.circle,
                                    border: selected
                                        ? Border.all(color: AppColors.primary, width: 2)
                                        : null,
                                  ),
                                  child: Center(child: Text(moods[i], style: const TextStyle(fontSize: 24))),
                                ),
                                const SizedBox(height: 4),
                                Text(labels[i], style: TextStyle(fontSize: 10, color: selected ? AppColors.primary : AppColors.textTertiary)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Calculated results
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('自动计算结果', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _ResultTile(label: '总睡眠时长', value: '${_tst.toStringAsFixed(1)}h')),
                          const SizedBox(width: 12),
                          Expanded(child: _ResultTile(label: '睡眠效率', value: '${(_se * 100).toStringAsFixed(0)}%')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TST = TIB(${tibH.toStringAsFixed(1)}h) - SL(${(_sleepLatency/60.0).toStringAsFixed(2)}h) - WASO(${(_wakeDuration/60.0).toStringAsFixed(2)}h)',
                        style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _submit,
                    child: const Text('保存日记', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: widget.currentIndex, onTap: widget.onTap),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle({required this.text});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryMid, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  const _ResultTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
        ],
      ),
    );
  }
}
