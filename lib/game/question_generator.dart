import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'difficulty.dart';

class QuestionGenerator {
  final SharedPreferences _prefs;
  final Random _random = Random();
  final String _tierKey;
  final String _seenPrefix;
  final List<Tier> _tiers;
  final int _minTarget;
  final Set<int> _sessionSeen = {};
  int _tierIndex;

  QuestionGenerator._(SharedPreferences prefs, int tier, String mode,
      List<Tier> tiers, int minTarget)
      : _prefs = prefs,
        _tiers = tiers,
        _minTarget = minTarget,
        _tierIndex = tier.clamp(0, tiers.length - 1),
        _tierKey = '${mode}_current_tier',
        _seenPrefix = '${mode}_seen_tier_';

  static Future<QuestionGenerator> create({
    String mode = 'match',
    List<Tier>? tiers,
    int minTarget = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveTiers = tiers ?? kTiers;
    return QuestionGenerator._(
        prefs,
        prefs.getInt('${mode}_current_tier') ?? 0,
        mode,
        effectiveTiers,
        minTarget);
  }

  int get currentBits => _tiers[_tierIndex].bits;
  int get currentTier => _tierIndex + 1;
  int get tierSolvedCount => _getSeen().length;
  int get tierCap => _tiers[_tierIndex].cap;

  int next() {
    var available = _available();
    if (available.isEmpty) {
      _advanceTier();
      available = _available();
      // At max tier the session-seen set can fully block the (now-reset) tier
      // pool; clear it so we can keep generating instead of looping forever.
      if (available.isEmpty) {
        _sessionSeen.clear();
        available = _available();
      }
    }
    final target = available[_random.nextInt(available.length)];
    _markSeen(target);
    _sessionSeen.add(target);
    if (_getSeen().length >= _tiers[_tierIndex].cap) {
      _advanceTier();
    }
    return target;
  }

  List<int> _available() {
    final seen = _getSeen();
    return _tiers[_tierIndex]
        .targets
        .where((t) =>
            !seen.contains(t) && !_sessionSeen.contains(t) && t >= _minTarget)
        .toList();
  }

  Set<int> _getSeen() {
    return (_prefs.getStringList('$_seenPrefix$_tierIndex') ?? [])
        .map(int.parse)
        .toSet();
  }

  void _markSeen(int target) {
    final seen = _getSeen()..add(target);
    _prefs.setStringList(
        '$_seenPrefix$_tierIndex', seen.map((e) => '$e').toList());
  }

  void _advanceTier() {
    if (_tierIndex < _tiers.length - 1) {
      _tierIndex++;
      _prefs.setInt(_tierKey, _tierIndex);
    } else {
      _prefs.remove('$_seenPrefix$_tierIndex');
    }
  }
}
