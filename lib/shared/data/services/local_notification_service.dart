import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // await _flutterLocalNotificationsPlugin.initialize(
    //   const InitializationSettings(
    //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    //     iOS: DarwinInitializationSettings(),
    //   ),
    // );
  }
}
