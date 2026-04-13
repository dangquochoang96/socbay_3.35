import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocaNotificationService{
  LocaNotificationService();

  final _locaNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> initialize() async{

    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@drawable/img');

     DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
     
     final InitializationSettings settings = InitializationSettings(android: androidInitializationSettings,
     iOS: iosInitializationSettings);
     await _locaNotificationService.initialize(settings,
     onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future<NotificationDetails> _notificationDetails() async{
    const AndroidNotificationDetails  androidNotificationDetails =
        AndroidNotificationDetails('channelId', 'channelName',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true);
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();
    return const NotificationDetails(android: androidNotificationDetails,
    iOS: iosNotificationDetails);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
})async{
    final details = await _notificationDetails();
    await _locaNotificationService.show(id, title, body, details);
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required int seconds
  })async{
    final details = await _notificationDetails();
    await _locaNotificationService.zonedSchedule(id, title, body,
        tz.TZDateTime.from(DateTime.now().add(Duration(seconds: seconds)), tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String payload,
  })async{
    final details = await _notificationDetails();
    await _locaNotificationService.show(id, title, body, details, payload: payload);
  }
  void onSelectNotification(NotificationResponse? response) {
    print('payload ${response?.payload}');
    if(response?.payload != null && response!.payload!.isNotEmpty){
      onNotificationClick.add(response.payload);
    }
  }


}