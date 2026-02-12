import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// We need a standalone function for the service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // Initialize Local Notifications inside the isolate
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Notification Channel Setup (Must match the one in NotificationService or be new)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'fasting_timer_foreground', // id
    'Fasting Timer Service', // title
    description: 'Updates the fasting timer in the background',
    importance: Importance.low, // Low importance to avoid sound/vibration on every update
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
  );

  service.on('stopService').listen((event) async {
    await flutterLocalNotificationsPlugin.cancel(888); // Explicitly remove the notification
    service.stopSelf();
  });

  service.on('startTimer').listen((event) {
    final startTimeIso = event?['startTime'] as String?;
    final durationHours = event?['durationHours'] as int?;

    if (startTimeIso != null && durationHours != null) {
      final startTime = DateTime.parse(startTimeIso);
      final endTime = startTime.add(Duration(hours: durationHours));

      // Start the periodic timer
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (await service is AndroidServiceInstance) {
          if (await (service as AndroidServiceInstance).isForegroundService()) {
            final now = DateTime.now();
            final difference = now.difference(startTime);
            final remaining = endTime.difference(now);

            // If fasting is over
            if (remaining.isNegative) {
             // We could stop the service or show "Fasting Completed"
             // For now, let's keep showing elapsed time as "Overtime" or just "Completed"
             flutterLocalNotificationsPlugin.show(
                888,
                'Jejum Concluído! 🎉',
                'Você completou seu objetivo de ${durationHours}h.',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'fasting_timer_foreground',
                    'Fasting Timer Service',
                    icon: '@mipmap/launcher_icon',
                    ongoing: true,
                    importance: Importance.low, 
                    showWhen: false,
                  ),
                ),
              );
              timer.cancel(); // Stop updating
              service.stopSelf();
              return;
            }

            // Normal update
            final formattedElapsed = _formatDuration(difference);
            final formattedRemaining = _formatDuration(remaining);

            flutterLocalNotificationsPlugin.show(
              888,
              'Jejum em Andamento',
              'Decorrido: $formattedElapsed | Restante: $formattedRemaining',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'fasting_timer_foreground',
                  'Fasting Timer Service',
                  icon: '@mipmap/launcher_icon',
                  ongoing: true,
                  importance: Importance.low, // vital for silent updates
                  showWhen: false,
                ),
              ),
            );
          }
        }
      });
    }
  });
}

// Helper for formatting
String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
  return '${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Notification Channel Setup (Must match the one in onStart)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fasting_timer_foreground', // id
      'Fasting Timer Service', // title
      description: 'Updates the fasting timer in the background',
      importance: Importance.low, // Low importance to avoid sound/vibration on every update
    );

    // Create the channel on the main isolate to ensure it exists before service starts
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // This will be executed in the Android background service isolate
        onStart: onStart,

        // auto start false, we want to start it manually when fasting starts
        autoStart: false,
        isForegroundMode: true,
        
        notificationChannelId: 'fasting_timer_foreground',
        initialNotificationTitle: 'Mamba Fast Tracker',
        initialNotificationContent: 'Inicializando serviço de timer...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // Auto start service on iOS is tricky. Usually we rely on background fetch.
        // For this implementation, we will try to mirror the behavior but iOS 
        // will likely kill it quickly without audio/voip. 
        // We will just return true to let the plugin try.
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // iOS Background fetch handler (simplified)
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    // Determine if we should perform a fetch
    // Realistically, for a timer, iOS requires Push Notifications for updates 
    // or Live Activities. This is a placeholder for standard fetch.
    return true;
  }

  void startService(DateTime startTime, int durationHours) async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
    }
    
    // Pass data to the service
    service.invoke('startTimer', {
      'startTime': startTime.toIso8601String(),
      'durationHours': durationHours,
    });
  }

  void stopService() {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}
