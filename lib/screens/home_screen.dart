import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/sleep_diary.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final latest = state.latestDiary;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: '晚安，用户 🌙',
              subtitle: 'CBT-I 疗程第${state.currentWeek}周 · 第16天',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SleepMetricsCard(entry: latest),
                const SizedBox(height: 12),
                _TodayTasksCard(state: state),
                const SizedBox(height: 12),
                _SosQuickCard(onTap: () => onTap(3)),
                const SizedBox(height: 12),
                _RecommendedAudioCard(),
                const SizedBox(height: 12),
                _WeeklySeChart(state: state),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _SleepMetricsCard extends StatelessWidget {
  final SleepDiaryEntry? entry;
  const _SleepMetricsCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final se = entry != null ? (entry!.se * 100).toStringAsFixed(0) : '--';
    final tst = entry != null
        ? entry!.tst.toStringAsFixed(1)
        : '--';
    final sl = entry != null ? entry!.sleepLatency.toString() : '--';
    final wc = entry != null ? entry!.wakeCount.toString() : '--';
    final seVal = entry?.se ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              '昨晚睡眠',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
              children: [
                _MetricTile(value: '$se%', label: '睡眠效率', color: AppColors.primary),
                _MetricTile(value: '${tst}h', label: '总睡眠时长', color: Colors.black87),
                _MetricTile(value: '${sl}min', label: '入睡时间', color: Colors.black87),
                _MetricTile(value: wc, label: '夜醒次数', color: Colors.black87),
              ],
            ),
          ),
          if (entry != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: seVal >= 0.85 ? AppColors.greenBg : AppColors.amberBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      seVal >= 0.85 ? Icons.check_circle_outline : Icons.info_outline,
                      size: 16,
                      color: seVal >= 0.85 ? AppColors.greenText : AppColors.amberText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        seVal >= 0.85
                            ? '太棒了！昨晚睡眠效率达标，继续保持固定作息时间。'
                            : '睡眠效率偏低，请严格维持睡眠窗口（01:30 - 07:00）。',
                        style: TextStyle(
                          fontSize: 12,
                          color: seVal >= 0.85 ? AppColors.greenText : AppColors.amberText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricTile({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TodayTasksCard extends StatelessWidget {
  final AppState state;
  const _TodayTasksCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final diaryDone = state.hasFilledDiaryToday;
    final hygieneCount = state.selectedHygieneIndices.length;
    final tasks = [
      (title: '填写睡眠日记', done: diaryDone),
      (title: '固定时间起床 07:00', done: true),
      (title: '选择今日3条卫生习惯（已选 $hygieneCount/3）', done: hygieneCount >= 3),
      (title: '睡前放松训练（床外进行）', done: false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日任务', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...tasks.asMap().entries.map((e) {
            final task = e.value;
            final isInProgress = !task.done && e.key == 2 && state.selectedHygieneIndices.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.done ? AppColors.success : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.done ? AppColors.textSecondary : Colors.black87,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  _TaskBadge(done: task.done, inProgress: isInProgress),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final bool done;
  final bool inProgress;
  const _TaskBadge({required this.done, required this.inProgress});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)),
        child: const Text('已完成', style: TextStyle(fontSize: 10, color: AppColors.greenText, fontWeight: FontWeight.w600)),
      );
    }
    if (inProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(10)),
        child: const Text('进行中', style: TextStyle(fontSize: 10, color: AppColors.amberText, fontWeight: FontWeight.w600)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(10)),
      child: const Text('待完成', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
    );
  }
}

// SOS 快捷卡片
class _SosQuickCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SosQuickCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B6B), Color(0xFF1A1040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8A0BF).withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dark_mode, color: Color(0xFFE8A0BF), size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '凌晨睡不着？点这里',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '一起渡过今晚 · 3步缓解焦虑',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB0A8D0)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFE8A0BF)),
          ],
        ),
      ),
    );
  }
}

// 今晚推荐放松音频
class _RecommendedAudioCard extends StatefulWidget {
  const _RecommendedAudioCard();

  @override
  State<_RecommendedAudioCard> createState() => _RecommendedAudioCardState();
}

class _RecommendedAudioCardState extends State<_RecommendedAudioCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('今晚推荐', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '· 根据今日焦虑标签推荐',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _playing = !_playing),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4-7-8 腹式呼吸引导', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3),
                    Text(
                      '5-8分钟 · 睡前离床使用 · 在床外练习效果更好',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_playing) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.3,
                minHeight: 3,
                backgroundColor: AppColors.bgSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklySeChart extends StatelessWidget {
  final AppState state;
  const _WeeklySeChart({required this.state});

  @override
  Widget build(BuildContext context) {
    final values = state.weekSEValues;
    final today = DateTime.now();
    final days = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本周睡眠效率', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final se = values[i];
                final date = today.subtract(Duration(days: 6 - i));
                final isToday = date.day == today.day && date.month == today.month;
                final barH = se > 0 ? (se * 100).clamp(5.0, 100.0) : 4.0;
                final dayLabel = days[date.weekday - 1];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (se > 0)
                          Text(
                            '${(se * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 2),
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: se == 0
                                ? AppColors.bgSecondary
                                : isToday
                                    ? AppColors.primaryDark
                                    : AppColors.primaryMid,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isToday ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 24, height: 1.5, color: const Color(0xFFE53935)),
              const SizedBox(width: 6),
              const Text('目标线: 85%', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
