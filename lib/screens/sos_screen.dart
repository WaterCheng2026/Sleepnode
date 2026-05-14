import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/bottom_nav_bar.dart';

class SosScreen extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SosScreen({super.key, required this.currentIndex, required this.onTap});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  int _step = 0; // 0=intro, 1=breathe, 2=activity, 3=write, 4=done

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),
          Expanded(
            child: _step == 0
                ? _IntroView(onStart: () => setState(() => _step = 1))
                : _step == 1
                    ? _BreathingView(onDone: () => setState(() => _step = 2))
                    : _step == 2
                        ? _ActivityView(onDone: () => setState(() => _step = 3))
                        : _step == 3
                            ? _WriteView(onDone: () => setState(() => _step = 4))
                            : _DoneView(onRestart: () => setState(() => _step = 0)),
          ),
          if (_step > 0 && _step < 4)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: _StepIndicator(currentStep: _step),
            ),
          AppBottomNavBar(currentIndex: widget.currentIndex, onTap: widget.onTap),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dark_mode, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('凌晨支援', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('你不是一个人在醒着', style: TextStyle(fontSize: 12, color: Color(0xFFB0A8D0))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['让身体平静', '离开床', '写下担心'];
    return Row(
      children: List.generate(3, (i) {
        final active = i + 1 == currentStep;
        final done = i + 1 < currentStep;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: done || active ? const Color(0xFFE8A0BF) : Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${i + 1}. ${labels[i]}',
                  style: TextStyle(
                    fontSize: 10,
                    color: active ? Colors.white : Colors.white.withAlpha(128),
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────
// Step 0: Intro
// ──────────────────────────────────────────────────
class _IntroView extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nightlight_round, size: 72, color: Color(0xFFE8A0BF)),
          const SizedBox(height: 24),
          const Text(
            '凌晨睡不着？',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            '我们一起渡过今晚。\n接下来用3步帮你平静下来。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFFB0A8D0), height: 1.6),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A0BF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onStart,
              child: const Text('开始，一起渡过今晚', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '⚠️ 若你感到强烈的自伤念头，请拨打\n北京心理危机热线：010-82951332',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF8878A8)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Step 1: 4-7-8 Breathing
// ──────────────────────────────────────────────────
class _BreathingView extends StatefulWidget {
  final VoidCallback onDone;
  const _BreathingView({required this.onDone});

  @override
  State<_BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<_BreathingView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  int _phase = 0; // 0=inhale, 1=hold, 2=exhale
  int _countdown = 4;
  int _cycles = 0;
  Timer? _timer;
  bool _started = false;

  static const _phaseDurations = [4, 7, 8];
  static const _phaseLabels = ['吸气', '屏住', '呼气'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _start() {
    setState(() => _started = true);
    _runPhase(0, _phaseDurations[0]);
    _controller.forward();
  }

  void _runPhase(int phase, int duration) {
    setState(() {
      _phase = phase;
      _countdown = duration;
    });

    if (phase == 0) {
      _controller.duration = Duration(seconds: duration);
      _controller.forward(from: 0);
    } else if (phase == 2) {
      _controller.duration = Duration(seconds: duration);
      _controller.reverse(from: 1);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        final next = (phase + 1) % 3;
        if (next == 0) {
          setState(() => _cycles++);
          if (_cycles >= 3) {
            _timer?.cancel();
            return;
          }
        }
        _runPhase(next, _phaseDurations[next]);
      }
    });
  }

  bool get _breathingDone => _cycles >= 3;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '第一步：让身体先平静下来',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            '4-7-8 腹式呼吸法\n吸气4秒 · 屏住7秒 · 呼气8秒 × 3次',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFFB0A8D0), height: 1.5),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _started ? _scale.value : 0.7,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8A0BF).withAlpha(51),
                  border: Border.all(color: const Color(0xFFE8A0BF), width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _started ? _phaseLabels[_phase] : '准备好了吗',
                        style: const TextStyle(fontSize: 16, color: Color(0xFFE8A0BF), fontWeight: FontWeight.w600),
                      ),
                      if (_started) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$_countdown',
                          style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_started)
            Text(
              '第 ${_cycles + 1}/3 次',
              style: const TextStyle(fontSize: 13, color: Color(0xFFB0A8D0)),
            ),
          const Spacer(),
          if (!_started)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A0BF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _start,
                child: const Text('开始呼吸练习', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            )
          else if (_breathingDone)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A0BF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: widget.onDone,
                child: const Text('完成，下一步', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            )
          else
            TextButton(
              onPressed: widget.onDone,
              child: const Text('跳过，直接下一步', style: TextStyle(color: Color(0xFF8878A8))),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Step 2: Activity suggestions (离开床)
// ──────────────────────────────────────────────────
class _ActivityView extends StatelessWidget {
  final VoidCallback onDone;
  const _ActivityView({required this.onDone});

  static const _activities = [
    (icon: Icons.library_music_outlined, label: '听轻音乐'),
    (icon: Icons.menu_book_outlined, label: '读纸质书'),
    (icon: Icons.edit_note_outlined, label: '写心情日记'),
    (icon: Icons.hot_tub_outlined, label: '温水泡脚'),
    (icon: Icons.self_improvement_outlined, label: '轻度拉伸'),
    (icon: Icons.spa_outlined, label: '闻薰衣草香'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '第二步：离开床，做一件轻松的事',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            '根据刺激控制原则：睡不着就离开床，等困意来了再回去。',
            style: TextStyle(fontSize: 13, color: Color(0xFFB0A8D0), height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _activities.map((a) => _ActivityChip(icon: a.icon, label: a.label)).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8A0BF).withAlpha(77)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFE8A0BF)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '感到困意了再回去睡——不要硬躺在床上等待，这会加重条件性觉醒。',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB0A8D0), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8A0BF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onDone,
              child: const Text('好的，下一步', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChip extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ActivityChip({required this.icon, required this.label});

  @override
  State<_ActivityChip> createState() => _ActivityChipState();
}

class _ActivityChipState extends State<_ActivityChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _selected ? const Color(0xFFE8A0BF).withAlpha(51) : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selected ? const Color(0xFFE8A0BF) : Colors.white.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: _selected ? const Color(0xFFE8A0BF) : const Color(0xFFB0A8D0)),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                color: _selected ? Colors.white : const Color(0xFFB0A8D0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Step 3: Write down worries
// ──────────────────────────────────────────────────
class _WriteView extends StatefulWidget {
  final VoidCallback onDone;
  const _WriteView({required this.onDone});

  @override
  State<_WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<_WriteView> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AppState>().addSosThought(text);
    }
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '第三步：把现在的担心写下来',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            '把脑子里的担忧倒出来，明天再分析。现在只是记录，不需要解决。',
            style: TextStyle(fontSize: 13, color: Color(0xFFB0A8D0), height: 1.5),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(38)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.6),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '现在脑子里在想什么？写下来吧...',
                  hintStyle: TextStyle(color: Color(0xFF6B5F8C)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _saved ? Colors.white.withAlpha(51) : const Color(0xFFE8A0BF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _saved ? widget.onDone : () => _save(context),
              child: Text(
                _saved ? '已保存，明天再看 → 完成' : '保存，明天看',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (!_saved)
            TextButton(
              onPressed: widget.onDone,
              child: const Text('跳过，不想写', style: TextStyle(color: Color(0xFF8878A8))),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Step 4: Done / Warm closing
// ──────────────────────────────────────────────────
class _DoneView extends StatelessWidget {
  final VoidCallback onRestart;
  const _DoneView({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 64, color: Color(0xFFE8A0BF)),
          const SizedBox(height: 28),
          const Text(
            '很多人今晚和你一样醒着，\n这一夜会过去的，\n你会好起来的。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '等困意来了，再轻轻回到床上。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFFB0A8D0)),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: onRestart,
            child: const Text(
              '再练一遍',
              style: TextStyle(color: Color(0xFF8878A8), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
