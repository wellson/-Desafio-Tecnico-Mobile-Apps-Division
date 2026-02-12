import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:mamba_fast_tracker/core/utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showFastingStarted() async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.fastingChannelId,
      AppConstants.fastingChannelName,
      channelDescription: AppConstants.fastingChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      AppConstants.fastingStartNotificationId,
      '🟢 Jejum Iniciado!',
      'Seu período de jejum começou. Mantenha o foco!',
      details,
    );
  }

  Future<void> scheduleFastingEnd(DateTime endTime) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.fastingChannelId,
      AppConstants.fastingChannelName,
      channelDescription: AppConstants.fastingChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = tz.TZDateTime.from(endTime, tz.local);

    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.zonedSchedule(
        AppConstants.fastingEndNotificationId,
        '🎉 Jejum Concluído!',
        'Parabéns! Seu período de jejum terminou.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelFastingNotifications() async {
    await _plugin.cancel(AppConstants.fastingStartNotificationId);
    await _plugin.cancel(AppConstants.fastingEndNotificationId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
