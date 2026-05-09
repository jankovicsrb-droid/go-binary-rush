import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';
import '../theme.dart';

const _green = AppColors.g4;
const _muteGreen = AppColors.g1;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  QuestionGenerator? _generator;
  ScoreEngine? _scoreEngine;
  int _target = 0;
  List<int> _bits = [];
  bool _solved = false;
  bool _loaded = false;
  bool _hintOn = false;
  bool _hintUsed = false;
  int? _lastToggled;
  double _flashOpacity = 0.0;
  int _lapSolved = 0;
  int _lastEarned = 0;
  Timer? _advanceTimer;

  static const int _lapSize = 10;

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
      QuestionGenerator.create(mode: 'match'),
      ScoreEngine.create(mode: 'match'),
    ]);
    final gen = results[0] as QuestionGenerator;
    final score = results[1] as ScoreEngine;
    setState(() {
      _generator = gen;
      _scoreEngine = score;
      _target = gen.next();
      _bits = List.filled(gen.currentBits, 0);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
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

  void _toggleBit(int index) {
    if (_solved) return;
    final newBits = List<int>.from(_bits);
    newBits[index] = newBits[index] == 0 ? 1 : 0;
    setState(() {
      _bits = newBits;
      _lastToggled = index;
    });
    if (_computeValue(newBits) == _target) _triggerSuccess();
  }

  void _triggerSuccess() {
    HapticFeedback.mediumImpact();
    final earned = _scoreEngine!.onCorrect();
    setState(() {
      _solved = true;
      _flashOpacity = 1.0;
      _lastEarned = earned;
    });
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
    setState(() {
      _target = gen.next();
      _bits = List.filled(gen.currentBits, 0);
      _solved = false;
      _hintOn = false;
      _hintUsed = false;
      _lastToggled = null;
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E6E2E)),
        title: const Text(
          'GO BINARY RUSH',
          style: TextStyle(color: _green, fontSize: 15, letterSpacing: 4),
        ),
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
                _hud(gen, score),
                const Spacer(),
                _pips(),
                const SizedBox(height: 20),
                _targetDisplay(),
                const SizedBox(height: 32),
                _weightsRow(),
                const SizedBox(height: 8),
                BitRow(
                  bits: _bits,
                  onToggle: _toggleBit,
                  enabled: !_solved,
                  glowing: _solved,
                ),
                const SizedBox(height: 16),
                _hintArea(),
                const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  // _lapSolved = number of questions already completed in this lap (0..lapSize-1)
  // current question is always at index _lapSolved
  Widget _pips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_lapSize, (i) {
        final isPast = i < _lapSolved;
        final isCurrent = i == _lapSolved;
        Color borderColor;
        Color fillColor;
        List<BoxShadow>? glow;
        if (isPast) {
          fillColor = AppColors.g3;
          borderColor = AppColors.g3;
          glow = AppGlow.sm;
        } else if (isCurrent && _solved) {
          fillColor = AppColors.g4;
          borderColor = AppColors.g4;
          glow = AppGlow.sm;
        } else if (isCurrent) {
          fillColor = Colors.transparent;
          borderColor = AppColors.g2;
          glow = null;
        } else {
          fillColor = Colors.transparent;
          borderColor = AppColors.g1;
          glow = null;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: glow,
          ),
        );
      }),
    );
  }

  double _tileWidth(int n) {
    if (n <= 4) return 72;
    if (n <= 5) return 64;
    if (n <= 6) return 56;
    if (n <= 7) return 50;
    return 44;
  }

  Widget _weightsRow() {
    final n = _bits.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(n, (i) {
        final weight = 1 << (n - 1 - i);
        final isOn = _bits[i] == 1;
        final isLive = !_solved && _lastToggled == i;
        final color = isLive
            ? AppColors.amber
            : isOn
                ? AppColors.g4
                : AppColors.g1;
        return SizedBox(
          width: _tileWidth(n),
          child: Text(
            '$weight',
            textAlign: TextAlign.center,
            style: AppText.mono(size: 10, color: color),
          ),
        );
      }),
    );
  }

  Widget _hintArea() {
    if (_solved) return _livePreview();
    if (_hintOn) return _livePreview();
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

  Widget _livePreview() {
    final n = _bits.length;
    final parts = <Widget>[];
    for (int i = 0; i < n; i++) {
      final weight = 1 << (n - 1 - i);
      final isOn = _bits[i] == 1;
      if (i > 0) {
        parts.add(Text(' + ',
            style: AppText.mono(size: 11, color: AppColors.g1)));
      }
      parts.add(Text(
        '${_bits[i]}·$weight',
        style: AppText.mono(size: 11, color: isOn ? AppColors.g4 : AppColors.g1),
      ));
    }
    final value = _computeValue(_bits);
    final sumColor = _solved
        ? AppColors.g5
        : value == _target
            ? AppColors.g4
            : AppColors.g2;
    parts.add(Text(' = ', style: AppText.mono(size: 11, color: AppColors.g1)));
    parts.add(Text(
      '$value',
      style: AppText.mono(size: 14, color: sumColor, weight: FontWeight.w700),
    ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: parts,
    );
  }

  Widget _hud(QuestionGenerator gen, ScoreEngine score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tierStat(gen),
        _stat('SCORE', '${score.score}'),
        _stat('STREAK', '×${score.streak}'),
        _stat('BEST', '${score.highScore}'),
      ],
    );
  }

  Widget _tierStat(QuestionGenerator gen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('TIER', style: AppText.kicker()),
        const SizedBox(height: 2),
        Text('T${gen.currentTier}', style: AppText.hudValue()),
        Text('${gen.tierSolvedCount}/${gen.tierCap}',
            style: AppText.mono(size: 9, color: AppColors.g2)),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppText.kicker()),
        const SizedBox(height: 2),
        Text(value, style: AppText.hudValue()),
      ],
    );
  }

  Widget _targetDisplay() {
    return Column(
      children: [
        Text('TARGET', style: AppText.kicker(color: AppColors.g2)
            .copyWith(letterSpacing: 5)),
        const SizedBox(height: 8),
        Text('$_target', style: AppText.bigTarget()),
      ],
    );
  }

  Widget _feedback() {
    if (_solved) {
      final score = _scoreEngine!;
      return Column(
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _pulseAnim,
              child: Text(
                '[ OK ]  ✓  +$_lastEarned PTS  ·  ×${score.streak}',
                style: AppText.mono(size: 13, color: AppColors.g4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.g2),
              ),
              child: Text('NEXT  →',
                  style: AppText.mono(size: 13, color: AppColors.g3,
                      weight: FontWeight.w500)
                      .copyWith(letterSpacing: 4)),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
