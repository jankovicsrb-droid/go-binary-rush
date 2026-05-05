import 'package:shared_preferences/shared_preferences.dart';

class ScoreEngine {
  static const _keyHighScore = 'high_score';

  final SharedPreferences _prefs;
  int score = 0;
  int streak = 0;
  int highScore;

  ScoreEngine._(this._prefs) : highScore = _prefs.getInt(_keyHighScore) ?? 0;

  static Future<ScoreEngine> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ScoreEngine._(prefs);
  }

  void onCorrect() {
    streak++;
    score += 10 + (streak - 1) * 5;
    if (score > highScore) {
      highScore = score;
      _prefs.setInt(_keyHighScore, highScore);
    }
  }
}
