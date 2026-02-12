class AppConstants {
  static const String appName = 'Mamba Fast Tracker';
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  // Notification channels
  static const String fastingChannelId = 'fasting_channel';
  static const String fastingChannelName = 'Fasting Notifications';
  static const String fastingChannelDesc = 'Notifications for fasting start/end';

  // Notification IDs
  static const int fastingStartNotificationId = 1;
  static const int fastingEndNotificationId = 2;

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Database
  static const String databaseName = 'mamba_fast_tracker.db';
  static const int databaseVersion = 1;

  // Tables
  static const String fastingSessionsTable = 'fasting_sessions';
  static const String mealsTable = 'meals';
  static const String fastingProtocolsTable = 'fasting_protocols';
}
