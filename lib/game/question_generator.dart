import 'dart:math';

class QuestionGenerator {
  final Random _random = Random();
  int _lastTarget = -1;

  int next({int min = 1, int max = 15}) {
    int target;
    do {
      target = min + _random.nextInt(max - min + 1);
    } while (target == _lastTarget);
    _lastTarget = target;
    return target;
  }
}
