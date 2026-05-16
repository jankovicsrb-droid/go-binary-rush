import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrtSettings {
  static const prefsLevel = 'crt_intensity';
  static const levelOff = 0;
  static const levelLow = 1;
  static const levelMed = 2;
  static const levelFull = 3;
  static const labels = <String>['OFF', 'LOW', 'MED', 'FULL'];

  static final ValueNotifier<int> intensity = ValueNotifier<int>(levelFull);
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    intensity.value = prefs.getInt(prefsLevel) ?? levelFull;
    _loaded = true;
  }

  static Future<void> setLevel(int level) async {
    final clamped = level.clamp(levelOff, levelFull);
    intensity.value = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefsLevel, clamped);
  }
}
