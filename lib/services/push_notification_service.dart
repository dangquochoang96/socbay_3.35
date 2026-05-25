import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:socbay/firebase_options.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/services/local_notification_service.dart';
import 'package:socbay/services/navigation_service.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushNotificationService {
  PushNotificationService._internal();

  static final PushNotificationService instance =
      PushNotificationService._internal();

  static const String _fcmTokenStorageKey = 'fcmToken';
  static const String _currentTopicStorageKey = 'fcmCurrentTopic';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocaNotificationService _localNotificationService =
      LocaNotificationService.instance;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _localNotificationService.initialize();
    await _requestPermission();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _cacheCurrentToken();
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _localNotificationService.onNotificationClick.stream
        .listen(_handleLocalNotificationTap);

    _isInitialized = true;
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await SecureStorageUtil.shared.writeData(_fcmTokenStorageKey, token);
    }
    return token;
  }

  Future<void> setAuthenticatedUser(String userId) async {
    await _subscribeToUserTopic(userId);
    await _cacheCurrentToken();
  }

  Future<void> clearAuthenticatedUser() async {
    final currentTopic =
        await SecureStorageUtil.shared.readData(_currentTopicStorageKey);
    if (currentTopic != null && currentTopic.isNotEmpty) {
      await _messaging.unsubscribeFromTopic(currentTopic);
      await SecureStorageUtil.shared.deleteKey(_currentTopicStorageKey);
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _cacheCurrentToken() async {
    final token = await getToken();
    LoggerUtil.info('FCM token: ${token ?? "null"}');
  }

  Future<void> _handleTokenRefresh(String token) async {
    await SecureStorageUtil.shared.writeData(_fcmTokenStorageKey, token);
    LoggerUtil.info('FCM token refreshed: $token');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final payload = jsonEncode(message.data);
    await _localNotificationService.showNotification(
      id: message.hashCode,
      title: title ?? 'Thong bao',
      body: body ?? '',
      payload: payload,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(payload) as Map,
      );
      _navigateFromPayload(data);
    } catch (_) {
      _openDefaultNotificationScreen();
    }
  }

  Future<void> _subscribeToUserTopic(String userId) async {
    final topic = 'user_$userId';
    final currentTopic =
        await SecureStorageUtil.shared.readData(_currentTopicStorageKey);

    if (currentTopic == topic) {
      return;
    }

    if (currentTopic != null && currentTopic.isNotEmpty) {
      await _messaging.unsubscribeFromTopic(currentTopic);
    }

    await _messaging.subscribeToTopic(topic);
    await SecureStorageUtil.shared.writeData(_currentTopicStorageKey, topic);
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    final target = data['screen']?.toString();

    if (target == 'notification' || target == 'notification-list') {
      NavigationService.instance.navigateTo(Routes.notificationScreen);
      return;
    }

    if (target == 'task-list' || target == 'order-manager') {
      NavigationService.instance.navigateTo(Routes.orderManagerScreen);
      return;
    }

    _openDefaultNotificationScreen();
  }

  void _openDefaultNotificationScreen() {
    NavigationService.instance.navigateTo(Routes.notificationScreen);
  }
}
