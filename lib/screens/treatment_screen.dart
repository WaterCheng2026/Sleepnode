import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class TreatmentScreen extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TreatmentScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  bool _sctExpanded = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final week = state.currentWeek;
    const stages = ['基线', '评估', '干预一', '干预二', '认知', '巩固'];
    final sctChecked = state.sctItems.where((e) => e['checked'] == true).length;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: 'CBT-I 练习', subtitle: '第$week周 · 干预一'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 治疗初期预设
                _EarlyStagePresetCard(week: week),
                const SizedBox(height: 16),
                // Progress stages
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '疗程进度'),
                      const SizedBox(height: 14),
                      _StageProgress(currentStage: 2, stages: stages),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('本周任务', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                // SRT
                _ModuleCard(
                  icon: Icons.bedtime,
                  iconColor: AppColors.primary,
                  title: '睡眠限制 (SRT)',
                  description: '睡眠窗口：01:30 - 07:00（5.5小时）',
                  badge: '执行中',
                  badgeBg: AppColors.greenBg,
                  badgeColor: AppColors.greenText,
                ),
                const SizedBox(height: 10),
                // SCT
                _ModuleCard(
                  icon: Icons.single_bed,
                  iconColor: AppColors.primary,
                  title: '刺激控制 (SCT)',
                  description: '今日已完成 $sctChecked/7 项',
                  badge: '$sctChecked/7 完成',
                  badgeBg: AppColors.amberBg,
                  badgeColor: AppColors.amberText,
                  extra: Column(
                    children: [
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: sctChecked / 7,
                          minHeight: 6,
                          backgroundColor: AppColors.bgSecondary,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _sctExpanded = !_sctExpanded),
                        child: Row(
                          children: [
                            const Text('查看清单', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            Icon(_sctExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                      if (_sctExpanded) ...[
                        const SizedBox(height: 8),
                        ...state.sctItems.asMap().entries.map((e) {
                          final item = e.value;
                          return InkWell(
                            onTap: () => context.read<AppState>().toggleSctItem(e.key),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    item['checked'] == true ? Icons.check_box : Icons.check_box_outline_blank,
                                    size: 20,
                                    color: item['checked'] == true ? AppColors.primary : AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['title'] as String, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Sleep hygiene — 每日3条选择器
                _HygieneSelector(state: state),
                const SizedBox(height: 10),
                // Cognitive
                _ModuleCard(
                  icon: Icons.psychology_outlined,
                  iconColor: AppColors.amberText,
                  title: '认知重建',
                  description: '第4周解锁',
                  badge: '未解锁',
                  badgeBg: AppColors.bgSecondary,
                  badgeColor: AppColors.textTertiary,
                  locked: true,
                ),
                const SizedBox(height: 16),
                const Text('放松训练库', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                  '在床外使用，帮你建立自己的放松能力',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                _RelaxCard(
                  title: '4-7-8 腹式呼吸引导',
                  duration: '5-8分钟',
                  tag: '睡前离床推荐',
                  tagBg: AppColors.greenBg,
                  tagColor: AppColors.greenText,
                  description: '心跳加速、入睡困难时使用',
                ),
                const SizedBox(height: 10),
                _RelaxCard(
                  title: '正念身体扫描',
                  duration: '15分钟',
                  tag: '过度关注躯体型',
                  tagBg: AppColors.primaryLight,
                  tagColor: AppColors.primary,
                  description: '睡前离床，放松身体感知',
                ),
                const SizedBox(height: 10),
                _RelaxCard(
                  title: '渐进性肌肉放松 (PMR)',
                  duration: '20分钟',
                  tag: '躯体紧张型',
                  tagBg: AppColors.amberBg,
                  tagColor: AppColors.amberText,
                  description: '肌肉酸痛、全身紧绷时使用',
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

// 治疗初期预设卡片
class _EarlyStagePresetCard extends StatelessWidget {
  final int week;
  const _EarlyStagePresetCard({required this.week});

  @override
  Widget build(BuildContext context) {
    if (week > 4) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5FCF), Color(0xFF9C8FDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('治疗初期说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('你在第$week周', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '第1-3周可能比平时睡得更少、更难入睡，这不是变坏了，而是睡眠限制在重建你的睡眠驱动力。多数人第4周开始明显好转。',
            style: TextStyle(fontSize: 12, color: Colors.white, height: 1.6),
          ),
          const SizedBox(height: 12),
          _MiniProgressCurve(currentWeek: week),
        ],
      ),
    );
  }
}

class _MiniProgressCurve extends StatelessWidget {
  final int currentWeek;
  const _MiniProgressCurve({required this.currentWeek});

  @override
  Widget build(BuildContext context) {
    // 典型SE曲线：第1-3周下降，第4周回升，第5-8周稳定提升
    const labels = ['基线', 'W1', 'W2', 'W3', 'W4', 'W5', 'W6'];
    const values = [0.65, 0.55, 0.50, 0.53, 0.70, 0.80, 0.87];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final isCurrentWeek = i == currentWeek.clamp(0, 6);
              final barH = (values[i] * 48).clamp(4.0, 48.0);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCurrentWeek)
                        const Text('你在这', style: TextStyle(fontSize: 8, color: Colors.white))
                      else
                        const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: barH,
                        decoration: BoxDecoration(
                          color: isCurrentWeek ? Colors.white : Colors.white.withAlpha(102),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.map((l) => Text(l, style: const TextStyle(fontSize: 9, color: Colors.white70))).toList(),
        ),
      ],
    );
  }
}

// 每日3条卫生习惯选择器
class _HygieneSelector extends StatelessWidget {
  final AppState state;
  const _HygieneSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedHygieneIndices;
    final count = selected.length;

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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(31),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.checklist, color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日睡眠卫生习惯', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      count == 0 ? '从14条中选3条作为今日重点' : '已选 $count/3',
                      style: TextStyle(
                        fontSize: 12,
                        color: count == 3 ? AppColors.greenText : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: count == 3 ? AppColors.greenBg : AppColors.amberBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count/3',
                  style: TextStyle(
                    fontSize: 11,
                    color: count == 3 ? AppColors.greenText : AppColors.amberText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(AppState.hygienePool.length, (i) {
              final isSelected = selected.contains(i);
              final isFull = !isSelected && count >= 3;
              return GestureDetector(
                onTap: isFull ? null : () => context.read<AppState>().toggleHygieneHabit(i),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isFull ? 0.4 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          AppState.hygienePool[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (count == 3) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: AppColors.success),
                SizedBox(width: 6),
                Text('今日习惯已选好，明天填日记时再回顾', style: TextStyle(fontSize: 12, color: AppColors.greenText)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  final int currentStage; // 0-indexed
  final List<String> stages;

  const _StageProgress({required this.currentStage, required this.stages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(stages.length * 2 - 1, (i) {
            if (i.isOdd) {
              // connector line
              final stageIndex = i ~/ 2;
              final done = stageIndex < currentStage;
              return Expanded(
                child: Container(
                  height: 2,
                  color: done ? AppColors.primary : AppColors.border,
                ),
              );
            }
            final stageIndex = i ~/ 2;
            final done = stageIndex < currentStage;
            final active = stageIndex == currentStage;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.primary
                    : active
                        ? Colors.white
                        : AppColors.bgSecondary,
                border: active ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  '${stageIndex + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? Colors.white
                        : active
                            ? AppColors.primary
                            : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((s) => Text(s, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))).toList(),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String badge;
  final Color badgeBg;
  final Color badgeColor;
  final bool locked;
  final Widget? extra;

  const _ModuleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeBg,
    required this.badgeColor,
    this.locked = false,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(badge, style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            ?extra,
          ],
        ),
      ),
    );
  }
}

class _RelaxCard extends StatefulWidget {
  final String title;
  final String duration;
  final String tag;
  final Color tagBg;
  final Color tagColor;
  final String? description;

  const _RelaxCard({
    required this.title,
    required this.duration,
    required this.tag,
    required this.tagBg,
    required this.tagColor,
    this.description,
  });

  @override
  State<_RelaxCard> createState() => _RelaxCardState();
}

class _RelaxCardState extends State<_RelaxCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _playing = !_playing),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(widget.duration, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: widget.tagBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(widget.tag, style: TextStyle(fontSize: 10, color: widget.tagColor)),
                    ),
                  ],
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 3),
                  Text(widget.description!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
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
