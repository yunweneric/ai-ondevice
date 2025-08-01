import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:offline_ai/shared/shared.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request notification permissions
    await _requestNotificationPermissions();
  }

  /// Request notification permissions for both platforms
  Future<void> _requestNotificationPermissions() async {
    try {
      // Request permissions for iOS
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      AppLogger.i('iOS notification permission result: $result');

      // Request permissions for Android 13+ (API 33+)
      final bool? androidResult = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      AppLogger.i('Android notification permission result: $androidResult');
    } catch (e) {
      AppLogger.e('Error requesting notification permissions: $e');
    }
  }

  /// Handle notification response
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    AppLogger.i('Notification response received: ${response.payload}');
    // Handle notification tap if needed
  }

  /// Show download progress notification
  Future<void> showDownloadProgress({
    required String id,
    required String title,
    required int progress,
    required String speed,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'download_progress',
      'Download Progress',
      channelDescription: 'Shows download progress for AI models',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate a unique notification ID based on the download ID
    final notificationId = _generateNotificationId(id);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      'Progress: $progress% • Speed: $speed',
      notificationDetails,
      payload: 'download_progress',
    );
  }

  /// Generate a unique notification ID from download ID
  int _generateNotificationId(String downloadId) {
    // Create a hash from the download ID to get a consistent integer
    return downloadId.hashCode.abs();
  }

  /// Show download completion notification
  Future<void> showDownloadComplete({
    required String id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'download_complete',
      'Download Complete',
      channelDescription: 'Shows when downloads are completed',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = _generateNotificationId(id);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'download_complete',
    );
  }

  /// Show download error notification
  Future<void> showDownloadError({
    required String id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'download_error',
      'Download Error',
      channelDescription: 'Shows when downloads fail',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = _generateNotificationId(id);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'download_error',
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(String id) async {
    final notificationId = _generateNotificationId(id);
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // Check Android permissions
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final isGranted = await androidPlugin.areNotificationsEnabled();
        AppLogger.i('Android notifications enabled: $isGranted');
        return isGranted ?? false;
      }

      // Check iOS permissions
      final iosPlugin =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final isGranted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        AppLogger.i('iOS notifications enabled: $isGranted');
        return isGranted ?? false;
      }

      return false;
    } catch (e) {
      AppLogger.e('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions explicitly
  Future<bool> requestNotificationPermissions() async {
    try {
      bool granted = false;

      // Request Android permissions
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final androidResult = await androidPlugin.requestNotificationsPermission();
        AppLogger.i('Android notification permission result: $androidResult');
        granted = androidResult ?? false;
      }

      // Request iOS permissions
      final iosPlugin =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final iosResult = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        AppLogger.i('iOS notification permission result: $iosResult');
        granted = granted || (iosResult ?? false);
      }

      return granted;
    } catch (e) {
      AppLogger.e('Error requesting notification permissions: $e');
      return false;
    }
  }
}
