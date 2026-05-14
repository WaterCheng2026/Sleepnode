import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';
import '../models/sleep_diary.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class ProgressScreen extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ProgressScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final diaries = state.diaries;
    final streak = state.streakDays;

    final baseline = _avgOf(diaries.take(7).toList());
    final recent = _avgOf(diaries.length >= 7 ? diaries.sublist(diaries.length - 7) : diaries);

    final seImprove = recent.se - baseline.se;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: '我的进度',
              subtitle: '${diaries.length}天数据 · 持续改善中',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top metrics
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: [
                    _MetricTile(
                      value: '${(state.averageSE * 100).toStringAsFixed(0)}%',
                      label: '当前平均SE',
                      color: AppColors.primary,
                    ),
                    _MetricTile(
                      value: '+${(seImprove * 100).toStringAsFixed(0)}%',
                      label: '较基线提升',
                      color: AppColors.success,
                    ),
                    _MetricTile(
                      value: '${recent.tst.toStringAsFixed(1)}h',
                      label: '平均睡眠时长',
                      color: Colors.black87,
                    ),
                    _MetricTile(
                      value: '$streak天',
                      label: '连续打卡天数',
                      color: AppColors.primaryDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Heat map
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '30天睡眠日历'),
                      const SizedBox(height: 10),
                      _HeatMap(diaries: diaries),
                      const SizedBox(height: 10),
                      _ColorLegend(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // SE trend chart
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: 'SE 趋势（30天）'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: _SeTrendChart(diaries: diaries),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Metrics table
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardTitle(text: '睡眠指标对比'),
                      const SizedBox(height: 12),
                      _MetricsTable(
                        baselineSe: baseline.se,
                        currentSe: recent.se,
                        baselineSl: baseline.sl,
                        currentSl: recent.sl,
                        baselineTst: baseline.tst,
                        currentTst: recent.tst,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }

  _Averages _avgOf(List<SleepDiaryEntry> list) {
    if (list.isEmpty) return _Averages(se: 0, sl: 0, tst: 0);
    final se = list.map((e) => e.se).reduce((a, b) => a + b) / list.length;
    final sl = list.map((e) => e.sleepLatency.toDouble()).reduce((a, b) => a + b) / list.length;
    final tst = list.map((e) => e.tst).reduce((a, b) => a + b) / list.length;
    return _Averages(se: se, sl: sl, tst: tst);
  }
}

class _Averages {
  final double se;
  final double sl;
  final double tst;
  const _Averages({required this.se, required this.sl, required this.tst});
}

class _HeatMap extends StatelessWidget {
  final List<SleepDiaryEntry> diaries;
  const _HeatMap({required this.diaries});

  Color _cellColor(double? se) {
    if (se == null) return AppColors.bgSecondary;
    final pct = se * 100;
    if (pct < 70) return const Color(0xFFDCEAF8);
    if (pct < 80) return const Color(0xFFB5D4F4);
    if (pct < 85) return const Color(0xFF7FB9EE);
    if (pct < 90) return const Color(0xFF4A9DE3);
    return AppColors.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: List.generate(35, (i) {
        final dayOffset = 34 - i;
        final date = today.subtract(Duration(days: dayOffset));
        final d = DateTime(date.year, date.month, date.day);
        final entry = diaries.cast<SleepDiaryEntry?>().firstWhere(
              (e) => e!.date.year == d.year && e.date.month == d.month && e.date.day == d.day,
              orElse: () => null,
            );
        final isFuture = d.isAfter(DateTime(today.year, today.month, today.day));
        return Tooltip(
          message: entry != null ? 'SE: ${(entry.se * 100).toStringAsFixed(0)}%' : '',
          child: Container(
            decoration: BoxDecoration(
              color: isFuture ? Colors.transparent : _cellColor(entry?.se),
              borderRadius: BorderRadius.circular(4),
              border: isFuture ? null : Border.all(color: Colors.white, width: 0.5),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 9,
                  color: (entry != null && entry.se >= 0.80) ? Colors.white : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ColorLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (color: AppColors.bgSecondary, label: '无数据'),
      (color: const Color(0xFFDCEAF8), label: '<70%'),
      (color: const Color(0xFFB5D4F4), label: '70-80%'),
      (color: const Color(0xFF7FB9EE), label: '80-85%'),
      (color: const Color(0xFF4A9DE3), label: '85-90%'),
      (color: AppColors.primaryDark, label: '≥90%'),
    ];
    return Row(
      children: items.map((item) => Expanded(
        child: Column(
          children: [
            Container(height: 10, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 2),
            Text(item.label, style: const TextStyle(fontSize: 8, color: AppColors.textTertiary), textAlign: TextAlign.center),
          ],
        ),
      )).toList(),
    );
  }
}

class _SeTrendChart extends StatelessWidget {
  final List<SleepDiaryEntry> diaries;
  const _SeTrendChart({required this.diaries});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: 29 - i));
      final d = DateTime(date.year, date.month, date.day);
      final entry = diaries.cast<SleepDiaryEntry?>().firstWhere(
            (e) => e!.date.year == d.year && e.date.month == d.month && e.date.day == d.day,
            orElse: () => null,
          );
      if (entry != null) {
        spots.add(FlSpot(i.toDouble(), entry.se * 100));
      }
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 7,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                final date = today.subtract(Duration(days: 29 - idx));
                return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 85,
              color: const Color(0xFFE53935),
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => '85%',
                style: const TextStyle(fontSize: 9, color: Color(0xFFE53935)),
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (p, d, bar, i) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 1,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryLight.withAlpha(127),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsTable extends StatelessWidget {
  final double baselineSe, currentSe;
  final double baselineSl, currentSl;
  final double baselineTst, currentTst;

  const _MetricsTable({
    required this.baselineSe,
    required this.currentSe,
    required this.baselineSl,
    required this.currentSl,
    required this.baselineTst,
    required this.currentTst,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5, borderRadius: BorderRadius.circular(8)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        _headerRow(),
        _dataRow(
          '睡眠效率',
          '${(baselineSe * 100).toStringAsFixed(0)}%',
          '${(currentSe * 100).toStringAsFixed(0)}%',
          currentSe - baselineSe,
          higherIsBetter: true,
          isPercent: true,
        ),
        _dataRow(
          '入睡时间',
          '${baselineSl.toStringAsFixed(0)}min',
          '${currentSl.toStringAsFixed(0)}min',
          currentSl - baselineSl,
          higherIsBetter: false,
        ),
        _dataRow(
          '总睡眠',
          '${baselineTst.toStringAsFixed(1)}h',
          '${currentTst.toStringAsFixed(1)}h',
          currentTst - baselineTst,
          higherIsBetter: true,
        ),
      ],
    );
  }

  TableRow _headerRow() => TableRow(
        decoration: const BoxDecoration(color: AppColors.bgSecondary),
        children: ['指标', '基线', '当前'].map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            )).toList(),
      );

  TableRow _dataRow(String label, String baseline, String current, double diff,
      {bool higherIsBetter = true, bool isPercent = false}) {
    final improved = higherIsBetter ? diff > 0 : diff < 0;
    final arrow = improved ? '↑' : '↓';
    final diffAbs = diff.abs();
    final diffStr = isPercent
        ? '$arrow ${(diffAbs * 100).toStringAsFixed(0)}%'
        : '$arrow ${diffAbs.toStringAsFixed(isPercent ? 0 : 1)}';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(baseline, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Text(current, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text(
                diffStr,
                style: TextStyle(fontSize: 11, color: improved ? AppColors.success : const Color(0xFFE53935), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: child,
      );
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle({required this.text});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
}
