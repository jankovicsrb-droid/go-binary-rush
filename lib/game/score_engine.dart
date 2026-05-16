import 'package:shared_preferences/shared_preferences.dart';

class ScoreEngine {
  final SharedPreferences _prefs;
  final String _keyHighScore;
  int score = 0;
  int streak = 0;
  int highScore;

  ScoreEngine._(this._prefs, String mode)
      : _keyHighScore = '${mode}_high_score',
        highScore = _prefs.getInt('${mode}_high_score') ?? 0;

  static Future<ScoreEngine> create({String mode = 'match'}) async {
    final prefs = await SharedPreferences.getInstance();
    return ScoreEngine._(prefs, mode);
  }

  int _wrongsInRow = 0;
  int get wrongsInRow => _wrongsInRow;

  int onCorrect() {
    _wrongsInRow = 0;
    streak++;
    final earned = 10 + (streak - 1) * 5;
    score += earned;
    if (score > highScore) {
      highScore = score;
      _prefs.setInt(_keyHighScore, highScore);
    }
    _prefs.setInt('total_correct', (_prefs.getInt('total_correct') ?? 0) + 1);
    final bestStreak = _prefs.getInt('best_streak_ever') ?? 0;
    if (streak > bestStreak) _prefs.setInt('best_streak_ever', streak);
    return earned;
  }

  /// Returns true if the streak was just broken by this call.
  bool onWrong() {
    _wrongsInRow++;
    if (_wrongsInRow >= 2 && streak > 0) {
      streak = 0;
      _wrongsInRow = 0;
      return true;
    }
    return false;
  }

  void onHint() {
    score = (score - 2).clamp(0, 999999);
  }

  void onWrongLetter() {
    score = (score - 1).clamp(0, 999999);
  }
}
