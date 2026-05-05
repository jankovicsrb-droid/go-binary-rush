import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'difficulty.dart';

class QuestionGenerator {
  static const _keyTier = 'current_tier';
  static const _seenPrefix = 'seen_tier_';

  final SharedPreferences _prefs;
  final Random _random = Random();
  int _tierIndex;

  QuestionGenerator._(this._prefs, int tier)
      : _tierIndex = tier.clamp(0, kTiers.length - 1);

  static Future<QuestionGenerator> create() async {
    final prefs = await SharedPreferences.getInstance();
    return QuestionGenerator._(prefs, prefs.getInt(_keyTier) ?? 0);
  }

  int get currentBits => kTiers[_tierIndex].bits;
  int get currentTier => _tierIndex + 1;

  int next() {
    final available = _available();
    if (available.isEmpty) {
      _advanceTier();
      return next();
    }
    final target = available[_random.nextInt(available.length)];
    _markSeen(target);
    return target;
  }

  List<int> _available() {
    final seen = _getSeen();
    return kTiers[_tierIndex].targets.where((t) => !seen.contains(t)).toList();
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
    if (_tierIndex < kTiers.length - 1) {
      _tierIndex++;
      _prefs.setInt(_keyTier, _tierIndex);
    } else {
      _prefs.remove('$_seenPrefix$_tierIndex');
    }
  }
}
