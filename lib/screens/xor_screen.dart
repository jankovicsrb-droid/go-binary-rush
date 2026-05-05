import 'dart:math';
import 'package:flutter/material.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);
const Color _red = Color(0xFFFF4040);

class XorScreen extends StatefulWidget {
  const XorScreen({super.key});

  @override
  State<XorScreen> createState() => _XorScreenState();
}

class _XorScreenState extends State<XorScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  QuestionGenerator? _generator;
  ScoreEngine? _scoreEngine;
  List<int> _bitsA = [];
  List<int> _bitsB = [];
  List<int> _bitsC = [];
  int _xorTarget = 0;
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
      QuestionGenerator.create(mode: 'xor'),
      ScoreEngine.create(mode: 'xor'),
    ]);
    final gen = results[0] as QuestionGenerator;
    final score = results[1] as ScoreEngine;
    setState(() {
      _generator = gen;
      _scoreEngine = score;
      _loaded = true;
    });
    _newQuestion();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Generate A randomly, derive B so that A XOR B = xorTarget.
  // xorTarget comes from the generator (no-repeat tracked).
  void _newQuestion() {
    final gen = _generator!;
    final xorTarget = gen.next();
    final bits = gen.currentBits;
    final maxVal = (1 << bits) - 1;
    final a = _random.nextInt(maxVal + 1);
    final b = a ^ xorTarget;
    setState(() {
      _xorTarget = xorTarget;
      _bitsA = _toBits(a, bits);
      _bitsB = _toBits(b, bits);
      _bitsC = List.filled(bits, 0);
      _solved = false;
      _wrong = false;
    });
  }

  List<int> _toBits(int value, int numBits) =>
      List.generate(numBits, (i) => (value >> (numBits - 1 - i)) & 1);

  int _computeValue(List<int> bits) {
    int val = 0;
    for (int i = 0; i < bits.length; i++) {
      val += bits[i] * (1 << (bits.length - 1 - i));
    }
    return val;
  }

  void _toggleC(int index) {
    if (_solved) return;
    final newC = List<int>.from(_bitsC);
    newC[index] = newC[index] == 0 ? 1 : 0;
    setState(() => _bitsC = newC);
  }

  void _confirm() {
    if (_solved) return;
    if (_computeValue(_bitsC) == _xorTarget) {
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
    _newQuestion();
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
    final tier = _generator!.currentTier;
    final valC = _computeValue(_bitsC);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dimGreen),
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
                _modeHeader(),
                const SizedBox(height: 28),
                _fixedRow(label: 'A', bits: _bitsA),
                const SizedBox(height: 8),
                _fixedRow(label: 'B', bits: _bitsB),
                _divider(),
                _playerRow(valC),
                const SizedBox(height: 36),
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

  Widget _modeHeader() {
    return const Text(
      'A  ⊕  B  =  C',
      style: TextStyle(fontSize: 13, color: _dimGreen, letterSpacing: 4),
    );
  }

  Widget _fixedRow({required String label, required List<int> bits}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _dimGreen, letterSpacing: 2)),
        ),
        const SizedBox(width: 8),
        BitRow(
          bits: bits,
          onToggle: (_) {},
          enabled: false,
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 28),
          Container(height: 1, width: 260, color: _muteGreen),
        ],
      ),
    );
  }

  Widget _playerRow(int valC) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              child: Text('C',
                  style: TextStyle(
                      fontSize: 11, color: _dimGreen, letterSpacing: 2)),
            ),
            const SizedBox(width: 8),
            BitRow(
              bits: _bitsC,
              onToggle: _toggleC,
              enabled: !_solved,
              glowing: _solved,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '= $valC',
          style: TextStyle(
              fontSize: 18, color: _solved ? _green : _dimGreen),
        ),
      ],
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
