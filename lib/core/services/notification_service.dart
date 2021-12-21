import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  /// Singleton pattern
  static NotificationHelper? _instance;

  NotificationHelper._internal() {
    _instance = this;
    _init();
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> _init() async {
    await _setupLocalNotification();
  }

  Future<void> _setupLocalNotification() async {
    const channel = AndroidNotificationChannel(
      'channel id',
      'channel name',
      description: 'channel desc',
      importance: Importance.max,
    );

    /// Initialization Settings for Android
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Initialization Settings for iOS
    const initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    /// InitializationSettings for initializing settings for both platforms
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNormalNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          channelDescription: 'channel desc',
          priority: Priority.high,
          importance: Importance.max,
        ),
      ),
      payload: payload,
    );
  }
}
