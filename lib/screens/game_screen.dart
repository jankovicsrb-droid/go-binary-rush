import 'package:flutter/material.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);
const Color _red = Color(0xFFFF4040);

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
  bool _wrong = false;
  bool _loaded = false;
  double _flashOpacity = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

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
    setState(() => _bits = newBits);
  }

  void _confirm() {
    if (_solved) return;
    if (_computeValue(_bits) == _target) {
      _scoreEngine!.onCorrect();
      setState(() {
        _solved = true;
        _flashOpacity = 1.0;
      });
      _pulseController.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _flashOpacity = 0.0);
      });
    } else {
      setState(() => _wrong = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrong = false);
      });
    }
  }

  void _next() {
    _pulseController.stop();
    _pulseController.reset();
    final gen = _generator!;
    setState(() {
      _target = gen.next();
      _bits = List.filled(gen.currentBits, 0);
      _solved = false;
      _wrong = false;
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

    final currentValue = _computeValue(_bits);
    final score = _scoreEngine!;
    final tier = _generator!.currentTier;

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
                _hud(tier, score),
                const Spacer(),
                _targetDisplay(),
                const SizedBox(height: 44),
                BitRow(
                  bits: _bits,
                  onToggle: _toggleBit,
                  enabled: !_solved,
                  glowing: _solved,
                ),
                const SizedBox(height: 28),
                Text(
                  '= $currentValue',
                  style: TextStyle(
                    fontSize: 32,
                    color: _solved ? _green : _dimGreen,
                  ),
                ),
                const SizedBox(height: 44),
                _feedback(),
                const Spacer(),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _flashOpacity,
              duration: const Duration(milliseconds: 60),
              child: Container(color: const Color(0x2200FF41)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hud(int tier, ScoreEngine score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stat('TIER', 'T$tier'),
        _stat('SCORE', '${score.score}'),
        _stat('STREAK', '×${score.streak}'),
        _stat('BEST', '${score.highScore}'),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: _dimGreen, letterSpacing: 2)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 14, color: _green, letterSpacing: 1)),
      ],
    );
  }

  Widget _targetDisplay() {
    return Column(
      children: [
        const Text(
          'TARGET',
          style: TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 5),
        ),
        const SizedBox(height: 8),
        Text(
          '$_target',
          style: const TextStyle(
            fontSize: 80,
            color: _green,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _feedback() {
    if (_solved) {
      return Column(
        children: [
          FadeTransition(
            opacity: _pulseAnim,
            child: const Text(
              'CORRECT',
              style: TextStyle(fontSize: 26, color: _green, letterSpacing: 8),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _next,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: _green)),
              child: const Text(
                'NEXT  →',
                style: TextStyle(fontSize: 15, color: _green, letterSpacing: 5),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        AnimatedOpacity(
          opacity: _wrong ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: const Text(
            'WRONG',
            style: TextStyle(fontSize: 13, color: _red, letterSpacing: 5),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _confirm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            decoration: BoxDecoration(border: Border.all(color: _dimGreen)),
            child: const Text(
              'CONFIRM',
              style: TextStyle(fontSize: 15, color: _green, letterSpacing: 5),
            ),
          ),
        ),
      ],
    );
  }
}
