import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/application.dart';
import 'package:socbay/services/location_api_service.dart';
import 'package:socbay/services/location_task_handler.dart';

class LocationTrackingService {
  LocationTrackingService._internal();
  static final LocationTrackingService instance =
      LocationTrackingService._internal();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking_channel',
        channelName: 'Dịch vụ vị trí ca làm việc',
        channelDescription: 'Thông báo dịch vụ theo dõi hành trình ca làm việc kỹ thuật viên',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    // Tu dong in log khi Main Isolate nhan duoc vi tri tu Background Task
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data is Map<String, dynamic>) {
        if (data.containsKey('latitude')) {
          final totalKm = ((data['total_distance'] ?? 0) as num) / 1000.0;
          print(
            '📍 [LOCATION MAIN RECEIVE] 🟢 Tọa độ: Lat=${data['latitude']}, Lng=${data['longitude']} | Tổng đi: ${totalKm.toStringAsFixed(2)}km (Speed=${data['speed']}m/s)',
          );
        } else if (data.containsKey('message')) {
          print(
            '📥 [LOCATION MAIN RECEIVE] Thông điệp từ Background Task: ${data['message']}',
          );
        } else {
          print('📥 [LOCATION MAIN RECEIVE] Data: $data');
        }
      } else {
        print('📥 [LOCATION MAIN RECEIVE] Data: $data');
      }
    });
  }

  /// Xin đầy đủ quyền vị trí (Foreground & Background) và Thông báo
  Future<bool> requestPermissions() async {
    // 1. Kiểm tra / Xin quyền Notification (Android 13+)
    NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      notificationPermissionStatus =
          await FlutterForegroundTask.requestNotificationPermission();
    }

    // 2. Kiểm tra Dịch vụ Vị trí (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 3. Xin quyền Vị trí (Geolocator)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 4. Xin quyền Background Location (Android / iOS)
    if (permission == LocationPermission.whileInUse) {
      final bgStatus = await Permission.locationAlways.request();
      if (bgStatus.isDenied || bgStatus.isPermanentlyDenied) {
        // Vẫn có thể chạy khi Foreground Service đang hoạt động
      }
    }

    // 5. Kiểm tra quyền bỏ qua tối ưu hóa Pin trên Android
    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }

    return true;
  }

  /// Khởi chạy theo dõi vị trí ngầm (Chỉ dành riêng cho tài khoản Kỹ thuật viên)
  Future<bool> startTracking() async {
    // Tuyệt đối không cho phép tài khoản khách hàng hoặc tài khoản khác bật theo dõi
    final user = App.instance.userApp;
    if (user == null || user.isUserRole() != true) {
      print('⛔ [LOCATION SERVICE] Denied startTracking: User is not KTV!');
      return false;
    }

    init();

    print('🔒 [LOCATION SERVICE] Requesting location & notification permissions...');
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('❌ [LOCATION SERVICE] Permissions denied by user or GPS disabled!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      print('ℹ️ [LOCATION SERVICE] Service is already running.');
      return true;
    }

    // 1. Lấy vị trí ban đầu để gọi API startTrip
    Position? initialPos;
    try {
      initialPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('⚠️ [LOCATION SERVICE] Could not get initial position for startTrip: $e');
    }

    if (initialPos != null) {
      print('🚀 [LOCATION SERVICE] Calling API startTrip with (${initialPos.latitude}, ${initialPos.longitude})...');
      final tripId = await LocationApiService.startTrip(
        latitude: initialPos.latitude,
        longitude: initialPos.longitude,
      );
      print('✅ [LOCATION SERVICE] startTrip API returned trip_id: $tripId');
    }

    print('🚀 [LOCATION SERVICE] Starting Foreground Service...');
    final reqResult = await FlutterForegroundTask.startService(
      serviceId: 257,
      notificationTitle: 'Đang theo dõi ca làm việc',
      notificationText: 'Đã di chuyển: 0.00 km',
      notificationIcon: const NotificationIcon(metaDataName: 'ic_launcher'),
      callback: startCallback,
    );

    bool isSuccess = reqResult is ServiceRequestSuccess;
    print(isSuccess
        ? '✅ [LOCATION SERVICE] Foreground service started successfully!'
        : '❌ [LOCATION SERVICE] Failed to start foreground service: $reqResult');
    return isSuccess;
  }

  /// Dừng theo dõi vị trí
  Future<bool> stopTracking() async {
    print('🛑 [LOCATION SERVICE] Stopping shift and trip...');

    Position? currentPos;
    try {
      currentPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}

    final totalDistance = await LocationApiService.getTotalDistance();

    // 1. Gọi API stopTrip kèm tổng quãng đường đã di chuyển
    print('📡 [LOCATION SERVICE] Calling API stopTrip...');
    await LocationApiService.stopTrip(
      latitude: currentPos?.latitude,
      longitude: currentPos?.longitude,
      totalDistance: totalDistance,
    );

    // 2. Dừng service ngầm
    if (await FlutterForegroundTask.isRunningService) {
      print('🛑 [LOCATION SERVICE] Stopping foreground tracking service...');
      final reqResult = await FlutterForegroundTask.stopService();
      bool isSuccess = reqResult is ServiceRequestSuccess;
      print(isSuccess
          ? '✅ [LOCATION SERVICE] Foreground service stopped successfully!'
          : '❌ [LOCATION SERVICE] Failed to stop service: $reqResult');
      return isSuccess;
    }
    return true;
  }

  /// Kiểm tra trạng thái service đang chạy
  Future<bool> isTracking() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Lấy tổng quãng đường hiện tại của ca (tính theo km)
  Future<double> getCurrentShiftDistanceKm() async {
    final meters = await LocationApiService.getTotalDistance();
    return meters / 1000.0;
  }

  /// Lấy thời gian bắt đầu ca
  Future<DateTime?> getShiftStartTime() async {
    return await LocationApiService.getTripStartTime();
  }

  /// Đăng ký nhận dữ liệu vị trí đẩy về Main Isolate
  void addTaskDataCallback(Function(dynamic data) callback) {
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  /// Hủy đăng ký nhận dữ liệu
  void removeTaskDataCallback(Function(dynamic data) callback) {
    FlutterForegroundTask.removeTaskDataCallback(callback);
  }
}
