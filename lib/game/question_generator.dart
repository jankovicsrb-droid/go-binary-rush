import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'difficulty.dart';

class QuestionGenerator {
  final SharedPreferences _prefs;
  final Random _random = Random();
  final String _tierKey;
  final String _seenPrefix;
  int _tierIndex;

  QuestionGenerator._(this._prefs, int tier, String mode)
      : _tierIndex = tier.clamp(0, kTiers.length - 1),
        _tierKey = '${mode}_current_tier',
        _seenPrefix = '${mode}_seen_tier_';

  static Future<QuestionGenerator> create({String mode = 'match'}) async {
    final prefs = await SharedPreferences.getInstance();
    return QuestionGenerator._(
        prefs, prefs.getInt('${mode}_current_tier') ?? 0, mode);
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
    if (_getSeen().length >= kTiers[_tierIndex].cap) {
      _advanceTier();
    }
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
      _prefs.setInt(_tierKey, _tierIndex);
    } else {
      _prefs.remove('$_seenPrefix$_tierIndex');
    }
  }
}
