import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  const NotificationService({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? const FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'tether_relationships';
  static const _channelName = 'Relationship reminders';
  static const _channelDescription = 'Timely reminders to invest in important relationships.';

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleRelationshipReminder({required int id, required String personName, required String reason, required DateTime when}) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      'TETHER · $personName',
      reason,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName, channelDescription: _channelDescription, importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
