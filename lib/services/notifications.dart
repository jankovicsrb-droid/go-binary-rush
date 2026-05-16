import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  static const prefsEnabled = 'daily_reminder_enabled';
  static const _notificationId = 1001;
  static const _channelId = 'daily_reminder';
  static const _channelName = 'Daily Reminder';
  static const _channelDesc = 'Reminds you that today\'s daily challenge is waiting';
  static const _reminderHour = 19;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to default tz.local; reminder still works, just not perfectly localized.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsEnabled) ?? false;
  }

  static Future<bool> enable(String agentName) async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    if (!granted) return false;

    await _schedule(agentName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsEnabled, true);
    return true;
  }

  static Future<void> disable() async {
    await init();
    await _plugin.cancel(id: _notificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsEnabled, false);
  }

  static Future<void> reschedule(String agentName) async {
    if (!await isEnabled()) return;
    await init();
    await _schedule(agentName);
  }

  static Future<void> _schedule(String agentName) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, _reminderHour);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }

    final body = agentName.isEmpty
        ? 'Daily ops awaiting. Tap to engage.'
        : 'AGENT $agentName — daily ops awaiting. Tap to engage.';

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'GO BINARY RUSH',
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
