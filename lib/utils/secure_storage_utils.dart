import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socbay/data/model/user_profile.dart';

class SecureStorageUtil {

  static const userAppStorageKey = 'userApp';
  static const tokenStorageKey = 'token';
  static const registerStaffKey = 'staffKey';
  static const currentUser = 'currentUser';
  // Singleton
  static final SecureStorageUtil _singleton = SecureStorageUtil._internal();

  factory SecureStorageUtil() => _singleton;

  SecureStorageUtil._internal();

  static SecureStorageUtil get shared => _singleton;

  // Variable
  final storage = const FlutterSecureStorage();

  Future<String?> readData(String key) async {
    final String? value = await storage.read(key: key);
    return value;
  }

  Future writeData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future deleteKey(String key) async {
    await storage.delete(key: key);
  }

  Future deleteAll() async {
    await storage.deleteAll();
  }
  Future setCurrentUserLogin(String key, UserProfile userProfile) async {
    await storage.write(key: key+"-id", value: userProfile.id.toString());
    await storage.write(key: key+"-username", value: userProfile.username);
    await storage.write(key: key+"-password", value: userProfile.password);
  }
  Future<UserProfile> getCurrentUserLogin() async {
    var id = await storage.read(key: currentUser+"-id");
    var username = await storage.read(key: currentUser+"-username");
    var password = await storage.read(key: currentUser+"-password");
    return UserProfile(id: int.parse(id??"0"), username: username, password: password);
  }
  Future logoutCurrentUser() async {
    await storage.delete(key: currentUser+"-id");
    await storage.delete(key: currentUser+"-username");
    await storage.delete(key: currentUser+"-password");
  }
}
