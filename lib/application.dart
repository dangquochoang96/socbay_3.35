import 'package:event_bus/event_bus.dart';
import 'package:socbay/data/model/local/account_db.dart';
import 'package:socbay/services/push_notification_service.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/secure_storage_utils.dart';
import 'data/model/user_profile.dart';

class App {
  ///Singleton factory
  App._privateConstructor() {
    eventBus.on().listen((event) {
      // Print the runtime type. Such a set up could be used for logging.
      LoggerUtil.info('listen event: ${event.runtimeType}');
    });
  }

  static final App _instance = App._privateConstructor();

  static App get instance => _instance;

  factory App() {
    return _instance;
  }

  static String versionApi = "api";
  EventBus eventBus = EventBus();

  UserProfile? userApp;

  AccountDb? initAccount;

  Future<void> onLogout() async {
    try {
      await PushNotificationService.instance.clearAuthenticatedUser();
    } catch (e) {
      LoggerUtil.info('FCM logout cleanup failed: $e');
    }
    userApp = null;
    await SecureStorageUtil.shared.deleteKey(SecureStorageUtil.tokenStorageKey);
    await SecureStorageUtil.shared.deleteKey(SecureStorageUtil.registerStaffKey);
    await SecureStorageUtil.shared.logoutCurrentUser();
  }
}
