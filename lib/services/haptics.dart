import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Haptics {
  static const prefsEnabled = 'haptics_enabled';
  static bool _enabled = true;
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(prefsEnabled) ?? true;
    _loaded = true;
  }

  static bool get enabled => _enabled;

  static Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsEnabled, value);
  }

  static void selectionClick() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  static void lightImpact() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (_enabled) HapticFeedback.heavyImpact();
  }
}
