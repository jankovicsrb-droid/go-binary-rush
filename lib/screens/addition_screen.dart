import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';
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
  double _flashOpacity = 0.0;

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
    if (_computeValue(_bitsA) + _computeValue(_bitsB) == _target) _triggerSuccess();
  }

  void _triggerSuccess() {
    HapticFeedback.mediumImpact();
    _scoreEngine!.onCorrect();
    setState(() {
      _solved = true;
      _flashOpacity = 1.0;
    });
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flashOpacity = 0.0);
    });
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
    final gen = _generator!;
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
                _hud(gen, score),
                const Spacer(),
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
        const Text('TIER',
            style: TextStyle(fontSize: 9, color: _dimGreen, letterSpacing: 2)),
        const SizedBox(height: 2),
        Text('T${gen.currentTier}',
            style: const TextStyle(fontSize: 14, color: _green, letterSpacing: 1)),
        Text('${gen.tierSolvedCount}/${gen.tierCap}',
            style: const TextStyle(fontSize: 8, color: _dimGreen, letterSpacing: 1)),
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
          ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _pulseAnim,
              child: const Text(
                'CORRECT',
                style: TextStyle(fontSize: 26, color: _green, letterSpacing: 8),
              ),
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
    return const SizedBox.shrink();
  }
}
