class ScoreEngine {
  int score = 0;
  int streak = 0;

  void onCorrect() {
    streak++;
    score += 10 + (streak - 1) * 5;
  }

  void reset() {
    score = 0;
    streak = 0;
  }
}
