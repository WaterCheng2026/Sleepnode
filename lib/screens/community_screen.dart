import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CommunityScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<_PostData> _posts = [
    _PostData(
      name: '夜晚猫头鹰 #7392',
      week: '第3周',
      se: '89%',
      seUp: true,
      content: '今天终于突破了85%！坚持睡眠限制真的很难，但今天看到效率突破了，感觉所有的煎熬都值得了 💪',
      hearts: 24,
      hugs: 12,
      muscles: 8,
    ),
    _PostData(
      name: '深夜游鱼 #2841',
      week: '第5周',
      se: '91%',
      seUp: true,
      content: '坚持到第5周了！认知重建那部分真的很有用，帮我把"必须睡够8小时"的执念打破了。现在反而睡得更好了。',
      hearts: 56,
      hugs: 31,
      muscles: 19,
    ),
    _PostData(
      name: '月光兔子 #1023',
      week: '第2周',
      se: '74%',
      seUp: false,
      content: '第一次SE超过70%！虽然还不够但进步了，刺激控制做起来不容易，但我在坚持 🌙',
      hearts: 18,
      hugs: 22,
      muscles: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final streak = state.streakDays;
    final hasToday = state.hasFilledDiaryToday;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: '打卡广场',
              subtitle: '今天 128 位战友已打卡',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // My streak card
                Container(
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
                          const Text('我的打卡连续天数', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$streak 天',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _MoonRow(streak: streak),
                      const SizedBox(height: 10),
                      if (!hasToday)
                        const Text(
                          '今日还未打卡 · 坚持完成今日日记吧！',
                          style: TextStyle(fontSize: 12, color: AppColors.amberText),
                        )
                      else
                        const Text(
                          '今日已打卡 ✓ 继续保持！',
                          style: TextStyle(fontSize: 12, color: AppColors.greenText),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showCheckInDialog(context),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('发布今日打卡', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('战友动态', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ..._posts.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PostCard(
                        data: p,
                        onReaction: (type) {
                          setState(() {
                            if (type == 'heart') p.hearts++;
                            if (type == 'hug') p.hugs++;
                            if (type == 'muscle') p.muscles++;
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: widget.currentIndex, onTap: widget.onTap),
        ],
      ),
    );
  }

  void _showCheckInDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今日打卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '今晚睡得怎么样？分享一句话...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('打卡成功！继续加油 💪'), backgroundColor: AppColors.success),
                  );
                },
                child: const Text('发布'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonRow extends StatelessWidget {
  final int streak;
  const _MoonRow({required this.streak});

  static const _phases = ['🌑', '🌒', '🌓', '🌔', '🌕'];

  String _moonFor(int index) {
    if (index >= streak) return '🌑';
    final cycle = index % 7;
    if (cycle < 5) return _phases[cycle];
    return '🌕';
  }

  @override
  Widget build(BuildContext context) {
    final total = ((streak ~/ 7) + 1) * 7;
    final show = total.clamp(7, 28);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(show, (i) => Text(_moonFor(i), style: const TextStyle(fontSize: 20))),
    );
  }
}

class _PostData {
  final String name;
  final String week;
  final String se;
  final bool seUp;
  final String content;
  int hearts;
  int hugs;
  int muscles;

  _PostData({
    required this.name,
    required this.week,
    required this.se,
    required this.seUp,
    required this.content,
    required this.hearts,
    required this.hugs,
    required this.muscles,
  });
}

class _PostCard extends StatelessWidget {
  final _PostData data;
  final void Function(String type) onReaction;

  const _PostCard({required this.data, required this.onReaction});

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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(data.week, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      'SE ${data.se}',
                      style: const TextStyle(fontSize: 12, color: AppColors.greenText, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      data.seUp ? ' ↑' : ' →',
                      style: const TextStyle(fontSize: 12, color: AppColors.greenText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.content, style: const TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              _ReactionBtn(emoji: '❤️', count: data.hearts, onTap: () => onReaction('heart')),
              const SizedBox(width: 12),
              _ReactionBtn(emoji: '🤗', count: data.hugs, onTap: () => onReaction('hug')),
              const SizedBox(width: 12),
              _ReactionBtn(emoji: '💪', count: data.muscles, onTap: () => onReaction('muscle')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionBtn extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback onTap;

  const _ReactionBtn({required this.emoji, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
