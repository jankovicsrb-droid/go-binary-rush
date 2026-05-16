import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_pips.dart';
import '../widgets/new_best_banner.dart';
import '../theme.dart';

const _green = AppColors.g4;
const _dimGreen = AppColors.g2;
const _muteGreen = AppColors.g1;

class AdditionScreen extends StatefulWidget {
  const AdditionScreen({super.key});

  @override
  State<AdditionScreen> createState() => _AdditionScreenState();
}

class _AdditionScreenState extends State<AdditionScreen>
    with SingleTickerProviderStateMixin {
  QuestionGenerator? _generator;
  ScoreEngine? _scoreEngine;
  int _target = 0;
  List<int> _bitsA = [];
  List<int> _bitsB = [];
  bool _solved = false;
  bool _loaded = false;
  bool _hintOn = false;
  bool _hintUsed = false;
  double _flashOpacity = 0.0;
  int _lapSolved = 0;
  int _lastEarned = 0;
  Timer? _advanceTimer;
  bool _newBestFlash = false;
  Timer? _newBestTimer;

  static const int _lapSize = GamePips.lapSize;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initGame();
  }

  Future<void> _initGame() async {
    final results = await Future.wait([
      QuestionGenerator.create(mode: 'addition'),
      ScoreEngine.create(mode: 'addition'),
    ]);
    final gen = results[0] as QuestionGenerator;
    final score = results[1] as ScoreEngine;
    final target = gen.next();
    setState(() {
      _generator = gen;
      _scoreEngine = score;
      _target = target;
      _bitsA = List.filled(gen.currentBits, 0);
      _bitsB = List.filled(gen.currentBits, 0);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _newBestTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  int _computeValue(List<int> bits) {
    int val = 0;
    for (int i = 0; i < bits.length; i++) {
      val += bits[i] * (1 << (bits.length - 1 - i));
    }
    return val;
  }

  void _toggle(List<int> row, int index, void Function(List<int>) update) {
    if (_solved) return;
    final newBits = List<int>.from(row);
    newBits[index] = newBits[index] == 0 ? 1 : 0;
    update(newBits);
    setState(() {});
    final valA = _computeValue(_bitsA);
    final valB = _computeValue(_bitsB);
    if (valA + valB == _target && valA > 0 && valB > 0) {
      _triggerSuccess();
    }
  }

  void _triggerSuccess() {
    HapticFeedback.mediumImpact();
    final earned = _scoreEngine!.onCorrect();
    final newBest = _scoreEngine!.consumeNewBestFlash();
    setState(() {
      _solved = true;
      _flashOpacity = 1.0;
      _lastEarned = earned;
      if (newBest) _newBestFlash = true;
    });
    if (newBest) {
      _newBestTimer?.cancel();
      _newBestTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _newBestFlash = false);
      });
    }
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flashOpacity = 0.0);
    });
    _advanceTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) _next();
    });
  }

  void _next() {
    _advanceTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    final gen = _generator!;
    final target = gen.next();
    setState(() {
      _target = target;
      _bitsA = List.filled(gen.currentBits, 0);
      _bitsB = List.filled(gen.currentBits, 0);
      _solved = false;
      _hintOn = false;
      _hintUsed = false;
      _lapSolved = (_lapSolved + 1) % _lapSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    final score = _scoreEngine!;
    final gen = _generator!;
    final valA = _computeValue(_bitsA);
    final valB = _computeValue(_bitsB);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dimGreen),
        title: const Text('GO BINARY RUSH',
            style: TextStyle(color: _green, fontSize: 15, letterSpacing: 4)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _muteGreen),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                GameHud(gen: gen, score: score),
                const Spacer(),
                GamePips(lapSolved: _lapSolved, solved: _solved),
                const SizedBox(height: 20),
                _targetDisplay(),
                const SizedBox(height: 28),
                _rowSection(
                  label: 'A',
                  bits: _bitsA,
                  value: valA,
                  onToggle: (i) => _toggle(_bitsA, i, (b) => _bitsA = b),
                ),
                const SizedBox(height: 16),
                _rowSection(
                  label: 'B',
                  bits: _bitsB,
                  value: valB,
                  onToggle: (i) => _toggle(_bitsB, i, (b) => _bitsB = b),
                ),
                const SizedBox(height: 20),
                _hintArea(),
                const SizedBox(height: 16),
                _feedback(),
                const Spacer(),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _flashOpacity,
              duration: const Duration(milliseconds: 60),
              child: Container(color: AppColors.g3.withValues(alpha: 0.13)),
            ),
          ),
          NewBestBanner(visible: _newBestFlash),
        ],
      ),
    );
  }

  Widget _rowSection({
    required String label,
    required List<int> bits,
    required int value,
    required void Function(int) onToggle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: AppText.kicker(color: AppColors.g2)
                    .copyWith(letterSpacing: 3)),
            if (_hintOn || _solved) ...[
              const SizedBox(width: 12),
              Text('= $value',
                  style: AppText.mono(
                      size: 18,
                      color: _solved ? AppColors.g4 : AppColors.g2)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        BitRow(
          bits: bits,
          onToggle: onToggle,
          enabled: !_solved,
          glowing: _solved,
        ),
      ],
    );
  }

  Widget _hintArea() {
    if (_solved || _hintOn) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        setState(() {
          _hintOn = true;
          if (!_hintUsed) {
            _hintUsed = true;
            _scoreEngine!.onHint();
          }
        });
      },
      child: Text(
        '[ HINT  ·  −2 ]',
        style: AppText.kicker(color: AppColors.amber).copyWith(letterSpacing: 3),
      ),
    );
  }

  Widget _targetDisplay() {
    return Column(
      children: [
        Text('TARGET',
            style: AppText.kicker(color: AppColors.g2).copyWith(letterSpacing: 5)),
        const SizedBox(height: 4),
        Text('$_target', style: AppText.bigTarget()),
        const SizedBox(height: 6),
        Text('A > 0   +   B > 0',
            style: AppText.kicker(color: AppColors.g2)
                .copyWith(letterSpacing: 3)),
      ],
    );
  }

  Widget _feedback() {
    if (!_solved) return const SizedBox.shrink();
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _pulseAnim,
            child: Text(
              '[ OK ]  ✓  +$_lastEarned PTS  ·  ×${_scoreEngine!.streak}',
              style: AppText.mono(size: 13, color: AppColors.g4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _next,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.g2)),
            child: Text('NEXT  →',
                style: AppText.mono(
                    size: 13, color: AppColors.g3, weight: FontWeight.w500)
                    .copyWith(letterSpacing: 4)),
          ),
        ),
      ],
    );
  }
}
