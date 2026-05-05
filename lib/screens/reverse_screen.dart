import 'package:flutter/material.dart';
import '../game/question_generator.dart';
import '../game/score_engine.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);
const Color _red = Color(0xFFFF4040);

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

  final TextEditingController _inputController = TextEditingController();
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
    _inputController.addListener(_onInput);
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
    _inputController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<int> _toBits(int value, int numBits) =>
      List.generate(numBits, (i) => (value >> (numBits - 1 - i)) & 1);

  void _onInput() {
    if (_solved || _wrong) return;
    final input = int.tryParse(_inputController.text.trim());
    if (input != null && input == _target) _onCorrect();
  }

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
    _scoreEngine!.onCorrect();
    _inputController.clear();
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
      _bits = _toBits(target, gen.currentBits);
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

    final score = _scoreEngine!;
    final tier = _generator!.currentTier;

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
                const Text(
                  'DECODE',
                  style: TextStyle(
                      fontSize: 11, color: _dimGreen, letterSpacing: 5),
                ),
                const SizedBox(height: 24),
                BitRow(
                  bits: _bits,
                  onToggle: (_) {},
                  enabled: false,
                  glowing: false,
                ),
                const SizedBox(height: 44),
                _inputArea(),
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

  Widget _inputArea() {
    return Column(
      children: [
        const Text(
          'DECIMAL VALUE?',
          style:
              TextStyle(fontSize: 10, color: _dimGreen, letterSpacing: 3),
        ),
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
            ),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle:
                  const TextStyle(color: _dimGreen, fontSize: 44),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: _dimGreen)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: _wrong ? _red : _green, width: 2),
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
          child: const Text(
            'WRONG',
            style: TextStyle(fontSize: 13, color: _red, letterSpacing: 5),
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
              style:
                  TextStyle(fontSize: 26, color: _green, letterSpacing: 8),
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
                style: TextStyle(
                    fontSize: 15, color: _green, letterSpacing: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
