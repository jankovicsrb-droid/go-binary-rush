import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/score_engine.dart';
import '../game/word_list.dart';
import '../widgets/game_pips.dart';
import '../theme.dart';

class HexWordScreen extends StatefulWidget {
  const HexWordScreen({super.key});

  @override
  State<HexWordScreen> createState() => _HexWordScreenState();
}

class _HexWordScreenState extends State<HexWordScreen>
    with SingleTickerProviderStateMixin {
  ScoreEngine? _score;
  SharedPreferences? _prefs;

  List<String> _pool = [];
  int _poolIdx = 0;
  String _word = '';
  int _revealed = 0;
  bool _solved = false;
  bool _wrongThisWord = false;

  int _lapSolved = 0;
  int _lastEarned = 0;
  bool _wrongFlash = false;
  Timer? _advanceTimer;
  Timer? _wrongTimer;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _keyRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _init();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _wrongTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final results = await Future.wait([
      ScoreEngine.create(mode: 'hex_word'),
      SharedPreferences.getInstance(),
    ]);
    final score = results[0] as ScoreEngine;
    final prefs = results[1] as SharedPreferences;
    final pool = List<String>.from(kWordList)..shuffle(Random());
    setState(() {
      _score = score;
      _prefs = prefs;
      _pool = pool;
      _poolIdx = 0;
    });
    _loadWord();
  }

  void _loadWord() {
    if (_pool.isEmpty) return;
    final word = _pool[_poolIdx % _pool.length];
    setState(() {
      _word = word;
      _revealed = 0;
      _solved = false;
      _wrongFlash = false;
      _wrongThisWord = false;
    });
  }

  List<String> _hexPairs(String word) => word.codeUnits
      .map((c) => c.toRadixString(16).padLeft(2, '0').toUpperCase())
      .toList();

  void _tapLetter(String letter) {
    if (_solved || _score == null || _word.isEmpty) return;
    final expected = _word[_revealed].toUpperCase();
    if (letter == expected) {
      HapticFeedback.selectionClick();
      setState(() => _revealed++);
      if (_revealed == _word.length) _triggerSolved();
    } else {
      _score!.onWrongLetter();
      HapticFeedback.lightImpact();
      _wrongTimer?.cancel();
      setState(() {
        _wrongFlash = true;
        _wrongThisWord = true;
      });
      _wrongTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _wrongFlash = false);
      });
    }
  }

  void _triggerSolved() {
    final earned = _score!.onCorrect();
    HapticFeedback.mediumImpact();
    _pulseCtrl.forward(from: 0);
    setState(() {
      _solved = true;
      _lastEarned = earned;
    });
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 700), _next);
    _saveProgress();
  }

  void _saveProgress() {
    final p = _prefs;
    if (p == null) return;
    final total = (p.getInt('hex_word_total') ?? 0) + 1;
    p.setInt('hex_word_total', total);
    if (!_wrongThisWord) {
      final perfect = (p.getInt('hex_word_perfect_count') ?? 0) + 1;
      p.setInt('hex_word_perfect_count', perfect);
    }
  }

  void _next() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
    final nextIdx = _poolIdx + 1;
    if (nextIdx >= _pool.length) _pool.shuffle(Random());
    setState(() {
      _lapSolved = (_lapSolved + 1) % GamePips.lapSize;
      _poolIdx = nextIdx % _pool.length;
    });
    _loadWord();
  }

  @override
  Widget build(BuildContext context) {
    if (_score == null) {
      return const Scaffold(
          backgroundColor: Colors.black, body: SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.g2),
        title: Text('HEX WORD', style: AppText.label()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.g1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _hud(),
          ),
          Container(height: 1, color: AppColors.g1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GamePips(lapSolved: _lapSolved, solved: _solved),
          ),
          Container(height: 1, color: AppColors.g1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ASCII  HEX', style: AppText.kicker()),
                  const SizedBox(height: 14),
                  _hexDisplay(),
                  const SizedBox(height: 22),
                  _letterBoxes(),
                  const SizedBox(height: 14),
                  SizedBox(height: 18, child: _solved ? _feedback() : null),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppColors.g1),
          const SizedBox(height: 10),
          _keyboard(),
          const SizedBox(height: 10),
          _nextButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _hud() {
    final score = _score!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _hudCell('SCORE', '${score.score}'),
        _hudCell('STREAK', '×${score.streak}'),
        _hudCell('BEST', '${score.highScore}'),
      ],
    );
  }

  Widget _hudCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppText.kicker()),
        const SizedBox(height: 2),
        Text(value, style: AppText.hudValue()),
      ],
    );
  }

  Widget _hexDisplay() {
    final pairs = _hexPairs(_word);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: pairs
          .map((p) => Text(
                p,
                style: AppText.mono(
                    size: 22,
                    color: AppColors.amber,
                    weight: FontWeight.w600),
              ))
          .toList(),
    );
  }

  Widget _letterBoxes() {
    if (_word.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (ctx, constraints) {
      final boxSlot =
          (constraints.maxWidth / _word.length).clamp(0.0, 50.0);
      final boxW = (boxSlot - 4.0).clamp(0.0, 46.0);
      final fontSize = (boxW * 0.45).clamp(10.0, 18.0);

      return ScaleTransition(
        scale: _pulseAnim,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_word.length, (i) {
            final isRevealed = i < _revealed;
            final isCurrent = i == _revealed && !_solved;
            final letter = isRevealed ? _word[i].toUpperCase() : '';

            final Color borderColor;
            final Color textColor;
            if (isRevealed) {
              borderColor = AppColors.g3;
              textColor = AppColors.g4;
            } else if (isCurrent && _wrongFlash) {
              borderColor = AppColors.red;
              textColor = AppColors.red;
            } else if (isCurrent) {
              borderColor = AppColors.g2;
              textColor = AppColors.g2;
            } else {
              borderColor = AppColors.g1;
              textColor = AppColors.g1;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: boxW,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                    color: borderColor, width: isCurrent ? 1.5 : 1),
                boxShadow: isRevealed ? AppGlow.sm : null,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: AppText.mono(
                    size: fontSize,
                    color: textColor,
                    weight: FontWeight.w700),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _feedback() {
    final score = _score!;
    return Text(
      '[ OK ] ✓  +$_lastEarned PTS  ·  ×${score.streak}',
      style: AppText.mono(size: 11, color: AppColors.g3),
    );
  }

  Widget _keyboard() {
    return Column(
      children: _keyRows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map(_key).toList(),
                ),
              ))
          .toList(),
    );
  }

  Widget _key(String letter) {
    return GestureDetector(
      onTap: () => _tapLetter(letter),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(
              color: _solved ? AppColors.g1 : AppColors.g2),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: AppText.mono(
              size: 12,
              color: _solved ? AppColors.g1 : AppColors.g3),
        ),
      ),
    );
  }

  Widget _nextButton() {
    return GestureDetector(
      onTap: _next,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.g2)),
        child: Text('NEXT', style: AppText.label()),
      ),
    );
  }
}
