import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/question_generator.dart';
import '../widgets/bit_row.dart';

const Color _green = Color(0xFF00FF41);
const Color _dimGreen = Color(0xFF2E6E2E);
const Color _muteGreen = Color(0xFF1A3A1A);
const Color _yellow = Color(0xFFFFFF00);
const Color _red = Color(0xFFFF4040);

enum _SBMode { match, reverse, addition, xor }

extension _SBModeLabel on _SBMode {
  String get label => const {
        _SBMode.match: 'MATCH',
        _SBMode.reverse: 'REVERSE',
        _SBMode.addition: 'ADDITION',
        _SBMode.xor: 'XOR',
      }[this]!;

  String get subtitle => const {
        _SBMode.match: 'decimal → binary',
        _SBMode.reverse: 'binary → decimal',
        _SBMode.addition: 'row_a + row_b = target',
        _SBMode.xor: 'a ⊕ b = ?',
      }[this]!;
}

class SpeedBurstScreen extends StatefulWidget {
  const SpeedBurstScreen({super.key});

  @override
  State<SpeedBurstScreen> createState() => _SpeedBurstScreenState();
}

class _SpeedBurstScreenState extends State<SpeedBurstScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  bool _selecting = true;
  bool _finished = false;

  _SBMode _mode = _SBMode.match;
  QuestionGenerator? _generator;
  SharedPreferences? _prefs;

  int _timeLeft = 60;
  Timer? _countdownTimer;

  int _solved = 0;
  int _highScore = 0;
  bool _newHighScore = false;
  bool _questionSolved = false;

  // Shared question target (match / reverse / addition / xor answer)
  int _target = 0;

  // Match
  List<int> _bits = [];

  // Reverse
  final TextEditingController _reverseInput = TextEditingController();
  bool _reverseWrong = false;

  // Addition
  List<int> _bitsA = [];
  List<int> _bitsB = [];

  // XOR
  List<int> _xorA = [];
  List<int> _xorB = [];
  List<int> _xorC = [];

  late AnimationController _flashController;
  late Animation<double> _flashAnim;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _flashAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashController.dispose();
    _reverseInput.dispose();
    super.dispose();
  }

  Future<void> _startMode(_SBMode mode) async {
    final key = 'speed_${mode.name}';
    final prefs = await SharedPreferences.getInstance();
    final gen = await QuestionGenerator.create(mode: key);
    setState(() {
      _mode = mode;
      _generator = gen;
      _prefs = prefs;
      _highScore = prefs.getInt('${key}_high_score') ?? 0;
      _solved = 0;
      _timeLeft = 60;
      _questionSolved = false;
      _newHighScore = false;
      _selecting = false;
      _finished = false;
    });
    _loadQuestion();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 1) {
        _countdownTimer?.cancel();
        _onTimeUp();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTimeUp() {
    final key = 'speed_${_mode.name}';
    final isNew = _solved > _highScore;
    if (isNew) {
      _highScore = _solved;
      _prefs?.setInt('${key}_high_score', _highScore);
    }
    setState(() {
      _timeLeft = 0;
      _finished = true;
      _newHighScore = isNew;
    });
  }

  void _loadQuestion() {
    final gen = _generator!;
    final bits = gen.currentBits;
    final target = gen.next();
    setState(() {
      _target = target;
      _questionSolved = false;
      _reverseWrong = false;
    });
    _reverseInput.clear();
    switch (_mode) {
      case _SBMode.match:
        setState(() => _bits = List.filled(bits, 0));
      case _SBMode.reverse:
        setState(() => _bits = _toBits(target, bits));
      case _SBMode.addition:
        setState(() {
          _bitsA = List.filled(bits, 0);
          _bitsB = List.filled(bits, 0);
        });
      case _SBMode.xor:
        final maxVal = (1 << bits) - 1;
        final a = _random.nextInt(maxVal + 1);
        setState(() {
          _xorA = _toBits(a, bits);
          _xorB = _toBits(a ^ target, bits);
          _xorC = List.filled(bits, 0);
        });
    }
  }

  void _onCorrect() {
    if (_questionSolved || _finished) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _questionSolved = true;
      _solved++;
    });
    _flashController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted && !_finished) _loadQuestion();
    });
  }

  List<int> _toBits(int v, int n) =>
      List.generate(n, (i) => (v >> (n - 1 - i)) & 1);

  int _val(List<int> b) {
    int v = 0;
    for (int i = 0; i < b.length; i++) {
      v += b[i] * (1 << (b.length - 1 - i));
    }
    return v;
  }

  void _toggleMatch(int i) {
    if (_questionSolved || _finished) return;
    final nb = List<int>.from(_bits)..[i] ^= 1;
    setState(() => _bits = nb);
    if (_val(nb) == _target) _onCorrect();
  }

  void _toggleAddA(int i) {
    if (_questionSolved || _finished) return;
    final nb = List<int>.from(_bitsA)..[i] ^= 1;
    setState(() => _bitsA = nb);
    if (_val(nb) + _val(_bitsB) == _target) _onCorrect();
  }

  void _toggleAddB(int i) {
    if (_questionSolved || _finished) return;
    final nb = List<int>.from(_bitsB)..[i] ^= 1;
    setState(() => _bitsB = nb);
    if (_val(_bitsA) + _val(nb) == _target) _onCorrect();
  }

  void _toggleXorC(int i) {
    if (_questionSolved || _finished) return;
    final nb = List<int>.from(_xorC)..[i] ^= 1;
    setState(() => _xorC = nb);
    if (_val(nb) == _target) _onCorrect();
  }

  void _checkReverse(String v) {
    if (_questionSolved || _finished) return;
    final input = int.tryParse(v.trim());
    if (input == _target) {
      _onCorrect();
    } else if (input != null && v.length >= _target.toString().length) {
      setState(() => _reverseWrong = true);
      _reverseInput.clear();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _reverseWrong = false);
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_selecting) return _selectScreen();
    if (_finished) return _finishedScreen();
    return _playScreen();
  }

  AppBar _appBar() => AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dimGreen),
        title: const Text('SPEED BURST',
            style: TextStyle(color: _green, fontSize: 15, letterSpacing: 4)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _muteGreen),
        ),
      );

  // ── Mode select ────────────────────────────────────────────────

  Widget _selectScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('SELECT MODE',
                style: TextStyle(
                    fontSize: 10, color: _dimGreen, letterSpacing: 5)),
            const SizedBox(height: 4),
            const Text('60 SECONDS  ·  MAXIMIZE SOLVED',
                style: TextStyle(
                    fontSize: 10, color: _muteGreen, letterSpacing: 2)),
            const SizedBox(height: 32),
            for (final m in _SBMode.values) ...[
              _modeItem(m),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeItem(_SBMode m) {
    return GestureDetector(
      onTap: () => _startMode(m),
      child: Row(
        children: [
          Text('[${m.index + 1}]',
              style: const TextStyle(
                  color: _green, fontSize: 13, letterSpacing: 1)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.label,
                  style: const TextStyle(
                      color: _green, fontSize: 15, letterSpacing: 3)),
              Text(m.subtitle,
                  style: const TextStyle(
                      color: _dimGreen, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Play ───────────────────────────────────────────────────────

  Widget _playScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _timerSection(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('SOLVED  ',
                        style: TextStyle(
                            fontSize: 10, color: _dimGreen, letterSpacing: 3)),
                    Text('$_solved',
                        style: const TextStyle(
                            fontSize: 20, color: _green)),
                  ],
                ),
                const Spacer(),
                _gameContent(),
                const Spacer(),
              ],
            ),
          ),
          IgnorePointer(
            child: FadeTransition(
              opacity: _flashAnim,
              child: Container(color: const Color(0x3300FF41)),
            ),
          ),
          if (_questionSolved)
            IgnorePointer(
              child: Center(
                child: Text('+1',
                    style: TextStyle(
                        fontSize: 52,
                        color: _green.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _timerSection() {
    final Color c = _timeLeft > 15
        ? _green
        : _timeLeft > 5
            ? _yellow
            : _red;
    return Column(
      children: [
        Text('$_timeLeft',
            style: TextStyle(
                fontSize: 52,
                color: c,
                fontWeight: FontWeight.bold,
                height: 1.0)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: _timeLeft / 60.0,
          backgroundColor: _muteGreen,
          valueColor: AlwaysStoppedAnimation<Color>(c),
          minHeight: 2,
        ),
      ],
    );
  }

  Widget _gameContent() {
    if (_generator == null) return const SizedBox.shrink();
    switch (_mode) {
      case _SBMode.match:
        return _matchUI();
      case _SBMode.reverse:
        return _reverseUI();
      case _SBMode.addition:
        return _additionUI();
      case _SBMode.xor:
        return _xorUI();
    }
  }

  Widget _matchUI() => Column(children: [
        const Text('TARGET',
            style:
                TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 5)),
        const SizedBox(height: 4),
        Text('$_target',
            style: const TextStyle(
                fontSize: 64,
                color: _green,
                fontWeight: FontWeight.bold,
                height: 1.0)),
        const SizedBox(height: 20),
        BitRow(
            bits: _bits,
            onToggle: _toggleMatch,
            enabled: !_questionSolved,
            glowing: _questionSolved),
      ]);

  Widget _reverseUI() => Column(children: [
        const Text('DECODE',
            style:
                TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 5)),
        const SizedBox(height: 16),
        BitRow(bits: _bits, onToggle: (_) {}, enabled: false),
        const SizedBox(height: 20),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _reverseInput,
            enabled: !_questionSolved,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style:
                TextStyle(fontSize: 40, color: _reverseWrong ? _red : _green),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle: const TextStyle(color: _dimGreen, fontSize: 40),
              border:
                  UnderlineInputBorder(borderSide: BorderSide(color: _dimGreen)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _reverseWrong ? _red : _green, width: 2)),
              enabledBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: _dimGreen)),
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _muteGreen)),
            ),
            onChanged: _checkReverse,
            onSubmitted: (_) => _checkReverse(_reverseInput.text),
          ),
        ),
      ]);

  Widget _additionUI() {
    final vA = _val(_bitsA), vB = _val(_bitsB);
    return Column(children: [
      const Text('TARGET',
          style: TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 5)),
      const SizedBox(height: 4),
      Text('$_target',
          style: const TextStyle(
              fontSize: 56,
              color: _green,
              fontWeight: FontWeight.bold,
              height: 1.0)),
      const SizedBox(height: 16),
      _addRowUI('A', _bitsA, vA, _toggleAddA),
      const SizedBox(height: 10),
      _addRowUI('B', _bitsB, vB, _toggleAddB),
    ]);
  }

  Widget _addRowUI(String lbl, List<int> bits, int v,
      void Function(int) onToggle) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(lbl,
            style:
                const TextStyle(fontSize: 11, color: _dimGreen, letterSpacing: 2)),
        const SizedBox(width: 8),
        Text('= $v',
            style: const TextStyle(fontSize: 16, color: _dimGreen)),
      ]),
      const SizedBox(height: 4),
      BitRow(
          bits: bits,
          onToggle: onToggle,
          enabled: !_questionSolved,
          glowing: _questionSolved),
    ]);
  }

  Widget _xorUI() {
    final vC = _val(_xorC);
    return Column(children: [
      const Text('A  ⊕  B  =  C',
          style:
              TextStyle(fontSize: 12, color: _dimGreen, letterSpacing: 3)),
      const SizedBox(height: 14),
      _xorRowUI('A', _xorA),
      const SizedBox(height: 6),
      _xorRowUI('B', _xorB),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(height: 1, width: 260, color: _muteGreen),
      ),
      Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
              width: 20,
              child: Text('C',
                  style: TextStyle(
                      fontSize: 11, color: _dimGreen, letterSpacing: 2))),
          const SizedBox(width: 8),
          BitRow(
              bits: _xorC,
              onToggle: _toggleXorC,
              enabled: !_questionSolved,
              glowing: _questionSolved),
        ]),
        const SizedBox(height: 6),
        Text('= $vC',
            style: const TextStyle(fontSize: 16, color: _dimGreen)),
      ]),
    ]);
  }

  Widget _xorRowUI(String lbl, List<int> bits) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          width: 20,
          child: Text(lbl,
              style: const TextStyle(
                  fontSize: 11, color: _dimGreen, letterSpacing: 2))),
      const SizedBox(width: 8),
      BitRow(bits: bits, onToggle: (_) {}, enabled: false),
    ]);
  }

  // ── Finished ───────────────────────────────────────────────────

  Widget _finishedScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("TIME'S UP",
                style: TextStyle(
                    fontSize: 16, color: _dimGreen, letterSpacing: 6)),
            const SizedBox(height: 20),
            Text('$_solved',
                style: const TextStyle(
                    fontSize: 96,
                    color: _green,
                    fontWeight: FontWeight.bold,
                    height: 1.0)),
            const Text('SOLVED',
                style: TextStyle(
                    fontSize: 11, color: _dimGreen, letterSpacing: 5)),
            const SizedBox(height: 28),
            if (_newHighScore)
              const Text('NEW BEST  ▲',
                  style: TextStyle(
                      fontSize: 13, color: _green, letterSpacing: 4))
            else
              Text('BEST  $_highScore',
                  style: const TextStyle(
                      fontSize: 13, color: _dimGreen, letterSpacing: 3)),
            const SizedBox(height: 44),
            _btn('PLAY AGAIN', _green, () => _startMode(_mode)),
            const SizedBox(height: 14),
            _btn('CHANGE MODE', _dimGreen,
                () => setState(() {
                      _selecting = true;
                      _finished = false;
                    })),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: color)),
        child: Text(label,
            style: TextStyle(
                fontSize: 14, color: color, letterSpacing: 4)),
      ),
    );
  }
}
