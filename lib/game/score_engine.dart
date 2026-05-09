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

  void onCorrect() {
    streak++;
    score += 10 + (streak - 1) * 5;
    if (score > highScore) {
      highScore = score;
      _prefs.setInt(_keyHighScore, highScore);
    }
  }

  void onHint() {
    score = (score - 2).clamp(0, 999999);
  }
}
