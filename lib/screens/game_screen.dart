import 'package:flutter/material.dart';
import '../game/question_generator.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final QuestionGenerator _generator = QuestionGenerator();
  late int _target;
  List<int> _bits = [0, 0, 0, 0];
  bool _solved = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _target = _generator.next();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnim = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    final newBits = List<int>.from(_bits);
    newBits[index] = newBits[index] == 0 ? 1 : 0;
    final correct = _computeValue(newBits) == _target;
    setState(() {
      _bits = newBits;
      _solved = correct;
    });
    if (correct) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _next() {
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _target = _generator.next();
      _bits = List.filled(4, 0);
      _solved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int currentValue = _computeValue(_bits);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'GO BINARY RUSH',
          style: TextStyle(
            color: _green,
            fontSize: 15,
            letterSpacing: 4,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF0F2A0F)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TARGET',
              style: TextStyle(
                fontSize: 11,
                color: _dimGreen,
                letterSpacing: 5,
              ),
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
            const SizedBox(height: 44),
            BitRow(
              bits: _bits,
              onToggle: _toggleBit,
              enabled: !_solved,
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
            AnimatedOpacity(
              opacity: _solved ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _pulseAnim,
                    child: const Text(
                      'CORRECT',
                      style: TextStyle(
                        fontSize: 26,
                        color: _green,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _solved ? _next : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _green),
                      ),
                      child: const Text(
                        'NEXT  →',
                        style: TextStyle(
                          fontSize: 15,
                          color: _green,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
