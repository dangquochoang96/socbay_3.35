import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocaNotificationService {
  LocaNotificationService._internal();

  static final LocaNotificationService instance =
      LocaNotificationService._internal();

  final _locaNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _locaNotificationService.initialize(
      settings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
    _isInitialized = true;
  }

  Future<NotificationDetails> _notificationDetails({
    bool useTaskSound = false,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          useTaskSound ? 'socbay_tasks_channel' : 'socbay_push_channel',
          useTaskSound ? 'Socbay Task Notifications' : 'Socbay Notifications',
          channelDescription: useTaskSound
              ? 'Task notifications for Socbay'
              : 'Push notifications for Socbay',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: useTaskSound
              ? const RawResourceAndroidNotificationSound(
                  'socbay_new_tasks',
                )
              : null,
        );
    final DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          sound: useTaskSound ? 'socbay_new_tasks.mp3' : null,
        );
    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool useTaskSound = false,
  }) async {
    final details = await _notificationDetails(useTaskSound: useTaskSound);
    await _locaNotificationService.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
    bool useTaskSound = false,
  }) async {
    final details = await _notificationDetails(useTaskSound: useTaskSound);
    await _locaNotificationService.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        DateTime.now().add(Duration(seconds: seconds)),
        tz.local,
      ),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String payload,
    bool useTaskSound = false,
  }) async {
    final details = await _notificationDetails(useTaskSound: useTaskSound);
    await _locaNotificationService.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void onSelectNotification(NotificationResponse? response) {
    print('payload ${response?.payload}');
    if (response?.payload != null && response!.payload!.isNotEmpty) {
      onNotificationClick.add(response.payload);
    }
  }
}
