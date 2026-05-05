import 'package:flutter/material.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);

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
    final valA = row == _bitsA ? _computeValue(newBits) : _computeValue(_bitsA);
    final valB = row == _bitsB ? _computeValue(newBits) : _computeValue(_bitsB);
    final correct = valA + valB == _target;
    if (correct) _scoreEngine!.onCorrect();
    setState(() {
      update(newBits);
      _solved = correct;
      if (correct) _flashOpacity = 1.0;
    });
    if (correct) {
      _pulseController.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _flashOpacity = 0.0);
      });
    }
  }

  void _next() {
    _pulseController.stop();
    _pulseController.reset();
    final gen = _generator!;
    final target = gen.next();
    setState(() {
      _target = target;
      _bitsA = List.filled(gen.currentBits, 0);
      _bitsB = List.filled(gen.currentBits, 0);
      _solved = false;
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
    final tier = _generator!.currentTier;
    final valA = _computeValue(_bitsA);
    final valB = _computeValue(_bitsB);

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
                _targetDisplay(),
                const SizedBox(height: 28),
                _rowSection(
                  label: 'A',
                  bits: _bitsA,
                  value: valA,
                  onToggle: (i) => _toggle(_bitsA, i, (b) => _bitsA = b),
                  showLabels: true,
                ),
                const SizedBox(height: 16),
                _rowSection(
                  label: 'B',
                  bits: _bitsB,
                  value: valB,
                  onToggle: (i) => _toggle(_bitsB, i, (b) => _bitsB = b),
                  showLabels: false,
                ),
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

  Widget _rowSection({
    required String label,
    required List<int> bits,
    required int value,
    required void Function(int) onToggle,
    required bool showLabels,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: _dimGreen, letterSpacing: 3)),
            const SizedBox(width: 12),
            Text('= $value',
                style: TextStyle(
                    fontSize: 18,
                    color: _solved ? _green : _dimGreen)),
          ],
        ),
        const SizedBox(height: 8),
        BitRow(
          bits: bits,
          onToggle: onToggle,
          enabled: !_solved,
          glowing: _solved,
          showLabels: showLabels,
        ),
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
        const SizedBox(height: 4),
        Text(
          '$_target',
          style: const TextStyle(
            fontSize: 64,
            color: _green,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
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
    return AnimatedOpacity(
      opacity: _solved ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: Column(
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
            onTap: _solved ? _next : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: _green)),
              child: const Text(
                'NEXT  →',
                style:
                    TextStyle(fontSize: 15, color: _green, letterSpacing: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
