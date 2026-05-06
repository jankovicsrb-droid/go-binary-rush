import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with SingleTickerProviderStateMixin {
  static const int _total = 10;

  SharedPreferences? _prefs;
  String _dateKey = '';
  List<int> _questions = [];
  int _current = 0;
  List<int> _bits = [];
  bool _solved = false;
  bool _done = false;
  bool _loaded = false;
  int _score = 0;
  int _bestScore = 0;
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
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);

    final pool = List.generate(15, (i) => i + 1)..shuffle(rng);
    final questions = pool.take(_total).toList();

    setState(() {
      _prefs = prefs;
      _dateKey = dateKey;
      _questions = questions;
      _bits = List.filled(4, 0);
      _bestScore = prefs.getInt('daily_${dateKey}_best') ?? 0;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _target => _questions[_current];

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
    if (_computeValue(newBits) == _target) _triggerSuccess();
  }

  void _triggerSuccess() {
    HapticFeedback.mediumImpact();
    setState(() {
      _score += 10;
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
    if (_current + 1 >= _total) {
      _finish();
      return;
    }
    setState(() {
      _current++;
      _bits = List.filled(4, 0);
      _solved = false;
    });
  }

  void _finish() {
    if (_score > _bestScore) {
      _bestScore = _score;
      _prefs!.setInt('daily_${_dateKey}_best', _bestScore);
    }
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dimGreen),
        title: const Text(
          'DAILY CHALLENGE',
          style: TextStyle(color: _green, fontSize: 15, letterSpacing: 4),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _muteGreen),
        ),
      ),
      body: _done ? _buildResults() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _progress(),
              const Spacer(),
              _targetDisplay(),
              const SizedBox(height: 44),
              BitRow(
                bits: _bits,
                onToggle: _toggleBit,
                enabled: !_solved,
                glowing: _solved,
              ),
              const SizedBox(height: 64),
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
    );
  }

  Widget _progress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_current + 1} / $_total',
          style: const TextStyle(
              fontSize: 13, color: _green, letterSpacing: 3),
        ),
        Text(
          'SCORE  $_score',
          style: const TextStyle(
              fontSize: 13, color: _dimGreen, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _targetDisplay() {
    return Column(
      children: [
        const Text(
          'TARGET',
          style:
              TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 5),
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
    if (!_solved) return const SizedBox.shrink();
    final isLast = _current + 1 >= _total;
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
            child: Text(
              isLast ? 'FINISH  →' : 'NEXT  →',
              style: const TextStyle(
                  fontSize: 15, color: _green, letterSpacing: 5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final isNewBest = _score > 0 && _score >= _bestScore;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHALLENGE COMPLETE',
            style: TextStyle(
                fontSize: 13, color: _dimGreen, letterSpacing: 4),
          ),
          const SizedBox(height: 24),
          Text(
            '$_score / ${_total * 10}',
            style: const TextStyle(
              fontSize: 64,
              color: _green,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          isNewBest
              ? const Text(
                  'NEW BEST',
                  style: TextStyle(
                      fontSize: 11, color: _green, letterSpacing: 5),
                )
              : Text(
                  'BEST  $_bestScore',
                  style: const TextStyle(
                      fontSize: 11, color: _dimGreen, letterSpacing: 3),
                ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: _green)),
              child: const Text(
                'BACK TO MENU',
                style: TextStyle(
                    fontSize: 13, color: _green, letterSpacing: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
