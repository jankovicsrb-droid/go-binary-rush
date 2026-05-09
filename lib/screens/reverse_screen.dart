import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_pips.dart';
import '../theme.dart';

const _green = AppColors.g4;
const _dimGreen = AppColors.g2;
const _muteGreen = AppColors.g1;
const _red = AppColors.red;

class ReverseScreen extends StatefulWidget {
  const ReverseScreen({super.key});

  @override
  State<ReverseScreen> createState() => _ReverseScreenState();
}

class _ReverseScreenState extends State<ReverseScreen>
    with SingleTickerProviderStateMixin {
  QuestionGenerator? _generator;
  ScoreEngine? _scoreEngine;
  int _target = 0;
  List<int> _bits = [];
  bool _solved = false;
  bool _wrong = false;
  bool _loaded = false;
  double _flashOpacity = 0.0;
  int _lapSolved = 0;
  int _lastEarned = 0;
  Timer? _advanceTimer;

  static const int _lapSize = GamePips.lapSize;

  final TextEditingController _inputController = TextEditingController();
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
      QuestionGenerator.create(mode: 'reverse'),
      ScoreEngine.create(mode: 'reverse'),
    ]);
    final gen = results[0] as QuestionGenerator;
    final score = results[1] as ScoreEngine;
    final target = gen.next();
    setState(() {
      _generator = gen;
      _scoreEngine = score;
      _target = target;
      _bits = _toBits(target, gen.currentBits);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _inputController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<int> _toBits(int value, int numBits) =>
      List.generate(numBits, (i) => (value >> (numBits - 1 - i)) & 1);

  void _submit() {
    if (_solved) return;
    final input = int.tryParse(_inputController.text.trim());
    if (input == null) return;
    if (input == _target) {
      _onCorrect();
    } else {
      setState(() => _wrong = true);
      _inputController.clear();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrong = false);
      });
    }
  }

  void _onCorrect() {
    HapticFeedback.mediumImpact();
    final earned = _scoreEngine!.onCorrect();
    _inputController.clear();
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
    final target = gen.next();
    setState(() {
      _target = target;
      _bits = _toBits(target, gen.currentBits);
      _solved = false;
      _wrong = false;
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
                Text('DECODE', style: AppText.kicker(color: AppColors.g2)
                    .copyWith(letterSpacing: 5)),
                const SizedBox(height: 24),
                BitRow(
                  bits: _bits,
                  onToggle: (_) {},
                  enabled: false,
                ),
                const SizedBox(height: 44),
                _inputArea(),
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

  Widget _inputArea() {
    return Column(
      children: [
        Text('DECIMAL VALUE?',
            style: AppText.kicker(color: AppColors.g2).copyWith(letterSpacing: 3)),
        const SizedBox(height: 16),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _inputController,
            enabled: !_solved,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: TextStyle(
              fontSize: 44,
              color: _wrong ? _red : _green,
              fontFamily: 'JetBrains Mono',
            ),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle: const TextStyle(color: _dimGreen, fontSize: 44),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: _dimGreen)),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: _wrong ? _red : _green, width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _dimGreen)),
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _muteGreen)),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          opacity: _wrong ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: Text('WRONG',
              style: AppText.mono(size: 13, color: _red).copyWith(letterSpacing: 5)),
        ),
        const SizedBox(height: 16),
        if (!_solved)
          GestureDetector(
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: _dimGreen)),
              child: Text('CONFIRM',
                  style: AppText.label().copyWith(letterSpacing: 5)),
            ),
          ),
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
                style: AppText.mono(size: 13, color: AppColors.g3,
                    weight: FontWeight.w500)
                    .copyWith(letterSpacing: 4)),
          ),
        ),
      ],
    );
  }
}
