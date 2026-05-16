import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaletteSettings {
  static const prefsIndex = 'palette_index';
  static const indexGreen = 0;
  static const indexAlt = 1;
  static const labels = <String>['GREEN', 'CYAN'];

  static final ValueNotifier<int> index = ValueNotifier<int>(indexGreen);
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    index.value = prefs.getInt(prefsIndex) ?? indexGreen;
    _loaded = true;
  }

  static Future<void> setIndex(int value) async {
    final clamped = value.clamp(indexGreen, indexAlt);
    index.value = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefsIndex, clamped);
  }
}
