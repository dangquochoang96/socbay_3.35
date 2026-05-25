import 'package:event_bus/event_bus.dart';
import 'package:socbay/data/model/local/account_db.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socbay/utils/secure_storage_utils.dart';
import 'data/model/user_profile.dart';

void _handleLogout() {
  OneSignal.logout();
  // OneSignal.User.removeAlias("user_id");
}

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
      _handleLogout();
    } catch (e) {
      LoggerUtil.info('OneSignal logout failed: $e');
    }
    userApp = null;
    await SecureStorageUtil.shared.deleteKey(SecureStorageUtil.tokenStorageKey);
    await SecureStorageUtil.shared.deleteKey(SecureStorageUtil.registerStaffKey);
    await SecureStorageUtil.shared.logoutCurrentUser();
  }
}
