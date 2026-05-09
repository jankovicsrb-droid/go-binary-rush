import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bit_row.dart';
import '../theme.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with SingleTickerProviderStateMixin {
  static const int _total = 10;
  // Bit width per question — progressively harder
  static const _bitsPerQ = [4, 4, 4, 5, 5, 5, 6, 6, 7, 8];

  SharedPreferences? _prefs;
  String _dateKey = '';
  List<int> _questions = [];
  int _current = 0;
  List<int> _bits = [];
  List<bool?> _results = List.filled(_total, null);
  bool _solved = false;
  bool _done = false;
  bool _alreadyDone = false;
  bool _loaded = false;
  int _score = 0;
  int _bestScore = 0;

  Timer? _advanceTimer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _init();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seed = now.year * 10000 + now.month * 100 + now.day;

    // Generate deterministic questions: top bit always set for clear bit-width
    final questions = <int>[];
    for (int i = 0; i < _total; i++) {
      final bits = _bitsPerQ[i];
      final min = 1 << (bits - 1);
      final max = (1 << bits) - 1;
      final rng = Random(seed + i * 7919);
      questions.add(min + rng.nextInt(max - min + 1));
    }

    final alreadyDone = prefs.getBool('daily_${dateKey}_done') ?? false;
    final best = prefs.getInt('daily_${dateKey}_best') ?? 0;

    setState(() {
      _prefs = prefs;
      _dateKey = dateKey;
      _questions = questions;
      _bits = List.filled(_bitsPerQ[0], 0);
      _results = List.filled(_total, null);
      _bestScore = best;
      _score = alreadyDone ? best : 0;
      _alreadyDone = alreadyDone;
      _loaded = true;
    });
  }

  int get _currentBits => _bitsPerQ[_current];
  int get _target => _questions[_current];

  int _val(List<int> bits) {
    int v = 0;
    for (int i = 0; i < bits.length; i++) {
      v += bits[i] * (1 << (bits.length - 1 - i));
    }
    return v;
  }

  void _toggleBit(int index) {
    if (_solved) return;
    final nb = List<int>.from(_bits)..[index] ^= 1;
    setState(() => _bits = nb);
    if (_val(nb) == _target) _triggerSuccess();
  }

  void _triggerSuccess() {
    HapticFeedback.mediumImpact();
    _pulseCtrl.repeat(reverse: true);
    final newResults = List<bool?>.from(_results)..[_current] = true;
    setState(() {
      _score += 10;
      _solved = true;
      _results = newResults;
    });
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 700), _next);
  }

  void _next() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    if (_current + 1 >= _total) {
      _finish();
      return;
    }
    setState(() {
      _current++;
      _bits = List.filled(_bitsPerQ[_current], 0);
      _solved = false;
    });
  }

  void _finish() {
    if (_score > _bestScore) {
      _bestScore = _score;
      _prefs!.setInt('daily_${_dateKey}_best', _bestScore);
    }
    _prefs!.setBool('daily_${_dateKey}_done', true);
    setState(() => _done = true);
  }

  static String _rank(int score) {
    if (score >= 100) return 'S';
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    return 'D';
  }

  static String _rankLabel(int score) {
    if (score >= 100) return 'ELITE';
    if (score >= 80) return 'EXPERT';
    if (score >= 60) return 'ADVANCED';
    if (score >= 40) return 'LEARNING';
    return 'TRAINING';
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
          backgroundColor: Colors.black, body: SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.g2),
        title: Text('DAILY CHALLENGE', style: AppText.label()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.g1),
        ),
      ),
      body: _alreadyDone
          ? _buildAlreadyDone()
          : _done
              ? _buildResults()
              : _buildGame(),
    );
  }

  // ── Already done ───────────────────────────────────────────────

  Widget _buildAlreadyDone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY\'S RESULT', style: AppText.kicker()),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.g1),
          const SizedBox(height: 32),
          Text(_rank(_bestScore),
              style: AppText.mono(
                  size: 72, color: AppColors.g4, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_rankLabel(_bestScore),
              style: AppText.mono(size: 11, color: AppColors.g2)),
          const SizedBox(height: 12),
          Text('$_bestScore / ${_total * 10}',
              style: AppText.hudValue(color: AppColors.g3)
                  .copyWith(fontSize: 22)),
          const SizedBox(height: 48),
          Text('NEXT CHALLENGE', style: AppText.kicker()),
          const SizedBox(height: 8),
          const _CountdownTimer(),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration:
                  BoxDecoration(border: Border.all(color: AppColors.g2)),
              child: Text('BACK TO MENU', style: AppText.label()),
            ),
          ),
        ],
      ),
    );
  }

  // ── Game ───────────────────────────────────────────────────────

  Widget _buildGame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _progressGrid(),
          const Spacer(),
          Text(
            '$_currentBits-BIT  ·  Q${_current + 1} OF $_total',
            style: AppText.kicker(color: AppColors.g2),
          ),
          const SizedBox(height: 10),
          Text('$_target', style: AppText.bigTarget()),
          const SizedBox(height: 36),
          BitRow(
              bits: _bits,
              onToggle: _toggleBit,
              enabled: !_solved,
              glowing: _solved),
          const SizedBox(height: 28),
          SizedBox(height: 60, child: _feedback()),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _progressGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_total, (i) {
        final done = _results[i] == true;
        final isCurrent = i == _current;

        final Color borderColor;
        final Color bgColor;
        final Widget inner;

        if (done && !isCurrent) {
          borderColor = AppColors.g3;
          bgColor = AppColors.g0;
          inner = Text('✓',
              style: AppText.mono(size: 9, color: AppColors.g3));
        } else if (isCurrent && _solved) {
          borderColor = AppColors.g4;
          bgColor = AppColors.g0;
          inner = Text('✓',
              style: AppText.mono(
                  size: 9, color: AppColors.g4, weight: FontWeight.w700));
        } else if (isCurrent) {
          borderColor = AppColors.g3;
          bgColor = Colors.transparent;
          inner = Text('${i + 1}',
              style: AppText.mono(size: 9, color: AppColors.g3));
        } else {
          borderColor = AppColors.g1;
          bgColor = Colors.transparent;
          inner = Text('${i + 1}',
              style: AppText.mono(size: 8, color: AppColors.g1));
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: bgColor,
            boxShadow: done || isCurrent ? AppGlow.sm : null,
          ),
          alignment: Alignment.center,
          child: inner,
        );
      }),
    );
  }

  Widget _feedback() {
    if (!_solved) return const SizedBox.shrink();
    final isLast = _current + 1 >= _total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _pulseAnim,
            child: Text('CORRECT',
                style: AppText.label()
                    .copyWith(fontSize: 20, letterSpacing: 8)),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _next,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration:
                BoxDecoration(border: Border.all(color: AppColors.g2)),
            child: Text(isLast ? 'FINISH →' : 'NEXT →',
                style: AppText.label()),
          ),
        ),
      ],
    );
  }

  // ── Results ────────────────────────────────────────────────────

  Widget _buildResults() {
    final rank = _rank(_score);
    final label = _rankLabel(_score);
    final isNewBest = _score >= _bestScore;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHALLENGE COMPLETE', style: AppText.kicker()),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.g1),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rank,
                  style: AppText.mono(
                      size: 72,
                      color: AppColors.g4,
                      weight: FontWeight.w700)),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppText.mono(size: 11, color: AppColors.g2)),
                    const SizedBox(height: 4),
                    Text('$_score / ${_total * 10}',
                        style: AppText.hudValue(color: AppColors.g3)
                            .copyWith(fontSize: 20)),
                    if (isNewBest)
                      Text('NEW BEST',
                          style: AppText.mono(
                              size: 9, color: AppColors.g4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _resultsGrid(),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration:
                  BoxDecoration(border: Border.all(color: AppColors.g2)),
              child: Text('BACK TO MENU', style: AppText.label()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_total, (i) {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.g3),
            color: AppColors.g0,
            boxShadow: AppGlow.sm,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✓',
                  style: AppText.mono(
                      size: 13,
                      color: AppColors.g4,
                      weight: FontWeight.w700)),
              Text('${_bitsPerQ[i]}b',
                  style: AppText.mono(size: 7, color: AppColors.g2)),
            ],
          ),
        );
      }),
    );
  }
}

// Live countdown to midnight
class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _time = _format();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _time = _format());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_time,
        style:
            AppText.hudValue(color: AppColors.g3).copyWith(fontSize: 28));
  }
}
